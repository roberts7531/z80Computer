/*----------------------------------------------------------------------*\
 |	Module conin to handle key translation				|
 |									|
 |  Copyright (c) 2015 by Jon Saxton (Lake Barrine, QLD, Australia)	|
 |									|
 | This file is part of yaze-ag - yet another Z80 emulator by ag.	|
 |----------------------------------------------------------------------|
 |									|
 | This module implements a state machine which examines keyboard input |
 | such as that generated by modern PC keyboards with "function keys"	|
 | and other keys labelled with symbols and words suggesting cursor	|
 | movement operations.  These keys typically generate multi-byte	|
 | sequences which can be augmented with "shift" keys such as "Ctrl",	|
 | "Alt" and plain "Shift".						|
 |									|
 | These multi-byte sequences are generally not understood by programs	|
 | written for CP/M and it is the job of this module and the others	|
 | which comprise the key translation sub-system to recognise these	|
 | sequences and translate them into sequences which CP/M programs do	|
 | understand.								|
 |									|
 | Note that there are other ways to make use of modern keyboards with-	|
 | out so much code.  For example, I have used the following shell	|
 | script to invoke a different emulator which does not have its own	|
 | key translation mechanism:						|
 |									|
 |	cd ~/z80pack/cpmsim						|
 |	xterm -fa monaco -fs 15 -g 80x40 -xrm \				|
 |	'xterm*VT100.translations: #override \				|
 |	<Key>Up: string(0x05) \n\					|
 |	<Key>Down: string(0x18) \n\					|
 |	None <Key>Right: string(0x04) \n\				|
 |	None <Key>Left: string(0x13) \n\				|
 |	None <Key>Prior: string(0x12) \n\				|
 |	None <Key>Next: string(0x03) \n\				|
 |	None <Key>Delete: string(0x07)' \				|
 |	-e ./cpm3							|
 |									|
 | That was certainly better than nothing.  The advantages of the key	|
 | translation system built into yaze-ag are at least:			|
 |  1.	it is much more comprehensive					|
 |  2.	multiple translation tables can be present and any of them	|
 |	can be loaded on demand without exiting CP/M			|
 | Some disadvantages are						|
 |  1.	it is a lot more complex.					|
 |  2.	maintenance demands a basic knowledge of C programming and some	|
 |	understanding of how state machines work			|
 |									|
 | Jon Saxton								|
 | Developer of key translation system for yaze-ag			|
 | Lake Barrine, QLD, Australia						|
\*----------------------------------------------------------------------*/


/*-----------------------------------------------------------------------
Yaze-ag is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
------------------------------------------------------------------------- */

#include "chan.h"
#include "ytypes.h"
#include "ktt.h"
#include <stdio.h>
#include <unistd.h>

#define SHOW 0

int utf8_illegal(BYTE b)
{
    switch (b)
    {
    case 0xC0:
    case 0xC1:
    case 0xF5:
    case 0xFF:
        return 1;
    }
    return 0;
}

extern void bios(int);

/*----------------------------------------------------------
//	 Things used by the console input routines
//---------------------------------------------------------- */

enum console_input_state
{
    IDLE,
    ESCAPE,
    F1234,
    F1234_SEMI,
    F1234_SHIFT,
    CSI,
    CYGWIN_FK,
    NUMBER,
    NUMBER_2,
    UTF8
};

struct _ci
    ci = { {0}, 0, 0 };

extern int serin(int chan);
extern int contest();

#if 0
    Coded but not used
/*------------------------------------------------------------------------
//				conqueued()
//
//	Returns the number of characters queued for input.
//------------------------------------------------------------------------ */

int conqueued()
{
    return ci.size;
}
#endif

/*------------------------------------------------------------------------
//				  conin()
//
//	Console input routine.
//
//	This is implemented as a state machine.
//
//	The idea is to translate cursor control keys as seen by the host
//	system into something useful for CP/M.
//
//	For most yaze-ag environments the cursor keys generate multi-byte
//	strings which correspond to output screen control sequences.  These
//	are not understood by CP/M which expects a single keystroke to
//	yield a single character.
//
//	This function returns an 8-bit unsigned number but bear in mind
//	that CP/M may limit the range to 7 bits.
//
//-----------------------------------------------------------------------*/

BYTE conin()
{
    BYTE ch;

    static WORD fk_map[] =
    {
	F1, F2, F3, F4, F5, Ignore, F6,
	F7, F8, F9, F10, Ignore, F11, F12,
	F13, F14, Ignore, F15, F16, Ignore, F17, F18, F19,
	F20, Ignore, Ignore, Ignore, Ignore
    };

    int
        fk_no = 0,
        shift_code = 0,
        utf8len = 0,	/* Initialise just to keep the compiler happy */
        state = IDLE;
    ui32
        key = 0;
    do
    {
	/*  If there is something queued up already then deliver it. */
        if (ci.size > 0)
        {
            --ci.size;
	    return ci.queue[ci.index++];
        }
	ci.index = ci.size = 0;
	ch = serin(CHNconin);

	switch (state)
	{
	/*------*/
	case IDLE:
	/*------*/
	    key = ci.index = ci.size = 0;
	    if (ch == 0x1B && contest())
	    {
		/* We have an escape quickly followed by something else.
		// Almost certainly we are seeing a multi-byte sequence. */
		state = ESCAPE;
	    }
	    else
	        key = ch;
	    if ((ch & 0xC0) == 0xC0)
	    {
		state = UTF8;
		if ((ch & 0xE0) == 0xC0)
		{
		    utf8len = 1;
		    key = ch & 0x1F;
		}
		else if ((ch & 0xF0) == 0xE0)
		{
		    utf8len = 2;
		    key = ch & 0x0F;
		}
		else if ((ch & 0xF8) == 0xF0)
		{
		    utf8len = 3;
		    key = ch & 0x07;
		}
		else if ((ch & 0xFC) == 0xF8)
		{
		    utf8len = 4;
		    key = ch & 0x03;
		}
		else if ((ch & 0xFE) == 0xFC)
		{
		    utf8len = 5;
		    key = ch & 0x01;
		}
		else
		{
		    key = Ignore;
		    state = IDLE;
		}
	    }
	    break;

	/*-------*/
	case UTF8:
	/*-------*/
	    if (utf8_illegal(ch) || (ch & 0xC0) != 0x80)
	    {
	        key = Ignore;
	        state = IDLE;
	    }
	    else
	    {
	        key = (key << 6) | (ch & 0x3F);
	        if (--utf8len == 0)
	        {
	            key |= KT_UNICODE;
	            state = IDLE;
		}
	    }
	    break;

	/*--------*/
	case ESCAPE:
	/*--------*/
	    switch (ch)
	    {
	    case 0x1B:		/* Two consecutive ESC */
		key = KT_ALT;
		break;

	    case '[':
		/* <esc>[ is probably a CSI but it may be Alt-ESC */
		if (contest())
        	{
		    state = CSI;
		    fk_no = 0;
		}
		else
		{
		    key = 0x1B | KT_ALT;
		    state = IDLE;
		}
		break;
	    case 'O':		/* Letter */
		/* <esc>Ox where x is P, Q, R or S is a common coding for
		// for F1 through F4. Also when using PuTTY it can be a cursor
		// movement key such as Ctrl-Up, Ctrl-Down etc. (See below.) */
		state = F1234;
		break;
	    default:
		/* We have previously seen an ESC and the thing
		// which followed did not complete a CSI.  That
		// implies an Alt chord. */
		key = ch | KT_ALT;
		state = IDLE;
	    }
	    break;

	/*-------*/
	case F1234:
	/*-------*/
	    /* We may have a function key.  F1 to F4 often generate
	    // <esc>Ox where O is an upper case letter (not a zero)
	    // and x is what we just saw.  The Home and End keys
	    // generate similar sequences.
	    //
	    // 2015-02-01 jrs on advice from ag ...
	    // When using PuTTY as a terminal emulator, <esc>Ox is generated
	    // by chording an arrow key with Control.  In that case, x is
	    // A, B, C or D for Up, Down, Right and Left respectively. */
	    state = IDLE;
	    switch (ch)
	    {
	    case 'H':
	        key |= Home;
		break;
	    case 'F':
		key |= End;
		break;
	    case 'P':	/* F1 */
	    case 'Q':	/* F2 */
	    case 'R':	/* F3 */
	    case 'S':	/* F4 */
		key |= fk_map[ch - 'P'];
		break;
	    case 'A':
		key = Up | KT_CONTROL;
		break;
	    case 'B':
		key = Down | KT_CONTROL;
		break;
	    case 'C':
		key = Right | KT_CONTROL;
		break;
	    case 'D':
		key = Left | KT_CONTROL;
		break;
	    case '1':
		state = F1234_SEMI;
		break;
	    default:
		key = Ignore;
	    }
	    break;

	/*------------*/
	case F1234_SEMI:
	/*------------*/
	    /* Expect to see a semicolon */
	    if (ch == ';')
		state = F1234_SHIFT;
	    else
	    {
		key = Ignore;
		state = IDLE;
	    }
	    break;
	/*-------------*/
	case F1234_SHIFT:
	/*-------------*/
	    /* Expect to see a shift code */
	    state = F1234;
	    switch (ch)
	    {
	    case '5':
		key = KT_CONTROL;
		break;
	    case '6':
		key = KT_SHIFT | KT_CONTROL;
		break;
	    case '4':
		key = KT_SHIFT | KT_ALT;
		break;
	    case '2':
		key |= KT_SHIFT;
		break;
	    case '3':
		key |= KT_ALT;
		break;
	    default:
		key = Ignore;
		state = IDLE;
	    }
	    break;
	/*-----*/
	case CSI:
	/*-----*/
	    /* We've seen an ISO 6429 command sequence initiator (CSI)
	    // <esc>[ and what follows should be a cursor movement
	    // control or the start of a function key sequence.
	    // If we get something which we don't recognise then we
	    // discard the entire sequence.

	    // Start by assuming we're going to resolve the state
	    // machine */
	    state = IDLE;

	    switch (ch)
	    {
	    default:
		key = Ignore;
		break;
	    case 'A':
		key = Up;
		break;
	    case 'B':
		key = Down;
		break;
	    case 'C':
		key = Right;
		break;
	    case 'D':
		key = Left;
		break;
	    case 'G':			/* PuTTY */
	    case 'E':			/* 102-key PC keyboard */
		key = NP5;
		break;
	    case 'F':			/* Cygwin terminal emulator */
		key = End;
		break;
	    case 'H':			/* Cygwin terminal emulator */
		key = Home;
		break;
	    case 'Z':			/* PuTTY */
		key = ReverseTab;
		break;
	    case '0':			/* <esc>[n ... */
	    case '1':
	    case '2':
	    case '3':
	    case '4':
	    case '5':
	    case '6':
	    case '7':
	    case '8':
	    case '9':
		fk_no = ch - '0';
		state = NUMBER;
		break;

	    case '[':
		/* Older versions of Cygwin (using rxvt) presented <esc>[[x
		// where x is A to E for function keys F1 to F5.  These were
		// special cases.  All the other keys followed the <esc>[n~
		// pattern common to other yaze-ag environments.
		//
		// There were logically twenty function keys as far as the
		// older Cygwin terminal emulator was concerned with F11 to
		// F20 being generated by using the shift key.  F11 and F12
		// were special cases and generated the same codes as
		// as shift-F1 and shift-F2 respectively in that F11 gene-
		// rated the same code as shift-F1.
		//
		// Here we just deal with the (unshifted) F1 to F5.
		// The other cases are handled by the general function
		// key decoder states. (NUMBER)
		//
		// (Note that newer Cygwins use mintty instead of rxvt and
		// mintty behaves much more like a standard UNIX xterm.) */

		state = CYGWIN_FK;
		break;
	    }
	    break;

	/*-----------*/
	case CYGWIN_FK:
	/*-----------*/
	    switch (ch)
	    {
	    case 'A':
	    case 'B':
	    case 'C':
	    case 'D':
	    case 'E':			/* 102-key PC keyboard */
		key = fk_map[ch - 'A'];
		break;
	    default:
		key = Ignore;
		break;
	    }
	    state = IDLE;
	    break;

	/*--------*/
	case NUMBER:
	/*--------*/
	    switch (ch)
	    {
	    case '0':
	    case '1':
	    case '2':
	    case '3':
	    case '4':
	    case '5':
	    case '6':
	    case '7':
	    case '8':
	    case '9':
		fk_no = fk_no * 10 + ch - '0';
		break;
	    case ';':	/* Number separator */
		state = NUMBER_2;
		shift_code = 0;
		break;
	    case '~':	/* End of sequence marker */
		state = IDLE;
		switch (fk_no)
		{
		case 1:
		    key |= Home;
		    break;
		case 2:
		    key |= Insert;
		    break;
		case 3:
		    key |= Delete;
		    break;
		case 4:
		    key |= End;
		    break;
		case 5:
		    key |= PageUp;
		    break;
		case 6:
		    key |= PageDown;
		    break;
		default:
		    if (10 < fk_no && fk_no < 35)
                        key |= fk_map[fk_no - 11];
                    else
			key = Ignore;
		    break;
		}
		break;
	    default:
		key = Ignore;
		state = IDLE;
	    }
	    break;

	/*----------*/
	case NUMBER_2:
	/*----------*/
	    /* We have seen esc[n; and we are now looking at a second
	    // number.  This usually describes a shift key or a combination
	    // of shift keys.
	    //
	    // fk_no holds the first number. */

	    switch (ch)
	    {
	    case '0':
	    case '1':
	    case '2':
	    case '3':
	    case '4':
	    case '5':
	    case '6':
	    case '7':
	    case '8':
	    case '9':
		shift_code = shift_code * 10 + ch - '0';
		break;
	    default:
		/* End of the number sequence.  The second number
		// is always the shift code.  What happens after we
		// deal with that depends on the end-of-sequence
		// character whe have. */
		switch (shift_code)
		{
		case 5:
		    key |= KT_CONTROL;
		    break;
                case 6:
		    key |= KT_SHIFT | KT_CONTROL;
		    break;
		case 4:
		    key |= KT_SHIFT | KT_ALT;
		    break;
		case 2:
		    key |= KT_SHIFT;
		    break;
		case 3:
		    key |= KT_ALT;
		    break;
		default:
		    key = Ignore;
		    break;
		}
		switch (ch)
		{
		case '~':	/* End-of-sequence sentinel */
		    state = IDLE;
		    if (10 < fk_no && fk_no < 35)
	                key |= fk_map[fk_no - 11];
		    else
			switch (fk_no)
			{
			case 2:
			    key |= Insert;
			    break;
			case 3:
			    key |= Delete;
			    break;
			case 5:
			    key |= PageUp;
			    break;
			case 6:
			    key |= PageDown;
			    break;
			default:
			    key = Ignore;
			};
		    break;
		default:
		    switch (fk_no)
		    {
		    case 1:
			switch (ch)
			{
			case 'A':
			    key |= Up;
			    break;
			case 'B':
			    key |= Down;
			    break;
			case 'C':
			    key |= Right;
			    break;
			case 'D':
			    key |= Left;
			    break;
			case 'F':
			    key |= End;
			    break;
			case 'H':
			    key |= Home;
			    break;
			default:
			    key = Ignore;
			}
			break;
		    default:
			key = Ignore;
		    }
                    state = IDLE;
		    break;
		}
	    }
	}
    }
    while (state != IDLE || key == Ignore || keyTrans(key, &ci));

    /*---------------------------------------------------------------------*\
     | If we just saw a SysRq keystroke then that usurps everything in the |
     | queue and we immediately exit to the monitor.  This is so we can    |
     | recover from a frozen CP/M session at any time.                     |
    \*---------------------------------------------------------------------*/

    if (ci.queue[ci.index] == SysRq)
    {
	printf("\r\nSysRq detected\r\n");
        /* Clear the input buffer so the bios() function doesn't
        // try to parse it as a command.  This means keytest will
        // report a sysRq as <00> rather than <FF> but that is
        // a very minor issue indeed. */
        ci.queue[0] = ci.size = 0;
        bios(254);
    }

    /* ci.size should ALWAYS be at least 1 */
    if (ci.size > 0)
    {
        --ci.size;
        return ci.queue[ci.index++];
    }
    return 0;		/* Serious error */
}

