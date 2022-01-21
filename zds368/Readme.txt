========================================================================
ZDS README.TXT File                                          
ZDS Release Version : 3.68 Release
Date: 02/18/2002
========================================================================
========================================================================
                        TABLE OF CONTENTS                               
========================================================================
                                                                        
  I. Introduction                                                     
 II. Product Support
III. Software Agreement 
 IV. Host Computer
  V. Software Installation
 VI. Electronic Information Services
VII. Revision History Summary

========================================================================
   I. INTRODUCTION                                                      
========================================================================
                                                                        
Congratulations on receiving ZiLOG's new  ZiLOG Developer Studio (ZDS). 
ZDS is used to develop software for ZiLOG's Z8/Z8Plus/Z89C00/eZ80/Z380
eZ80 microcontrollers and microprocessor families!  ZDS can be used either 
as an integrated component of ZiLOG's Support Product toolkit,  or as 
a stand-alone,  full-featured  macro assembler for  use  by assembly 
language programmers.
                                                                        
ZDS consists of the ZiLOG Macro Cross Assembler, Linker, and Editor. 
It includes Debugger support for Z8/Z8Plus/Z89C00/Z180/Z380/eZ80.                                                                 
                                                                        
The Assembler (Zilog Macro Cross Assembler, ZMASM) is highly compatible
with ZiLOG's ZASM/MOBJ and assemblers from 2500AD and PLC at the syntax
and  semantic level of  assembler instructions. Due to architecture 
differences among assemblers,  ZMASM  is not 100 percent compatible with 
the above assemblers. When porting codes from these assemblers into ZMASM
it is strongly recommended to consult the ZDS on-line help. The on-line 
help addresses ZMASM compatibility Vs. ZASM, 2500AD and PLC. For ZASM 
compatibility, ZDS 3.00 Beta 1 or later has an "Enable ZASM compatibility" 
option, which can be set from Project/Settings/Assembler/Category/Object.

========================================================================
 II. PRODUCT SUPPORT                                                 
========================================================================

If you experience any difficulties while using this product or if you
note any inaccuracies in the User's Manual, please consult the online
help first. When the online help does not solve your problem please
take advantage of our world-class Customer Support Center by visiting
the following web address:

http://register.zilog.com/login.asp?login=supportlogin

Your support request will receive next-business-day response, and we will
do our best to ensure that your problem is resolved within five business
days. If for any reason we cannot solve your problem within five business
days our support team will automatically escalate your call.

We welcome your suggestions!
                                                                        
========================================================================
 III. SOFTWARE AGREEMENT                                                 
========================================================================
                                                                        
ZiLOG, Inc.("ZiLOG") agrees to provide you its enclosed software,  under
the terms and conditions specified below:

  THIS IS A NON-TRANSFERABLE, SINGLE-COPY USER COMPUTER Software granted
  to you, by ZiLOG Inc.,  a  California  corporation  with  its  mailing
  address at  910 East Hamilton Avenue,  Campbell,  CA 95008.  The soft-
  ware should not sold,  reproduced or transmitted in any form or by any
  means, electronic or mechanical, for any purpose,  without the express
  written permission of ZiLOG Inc.
                                                                        
  (c) 2000 ZiLOG Inc. All right reserved.                                
                                                                        
========================================================================
 IV. HOST COMPUTER                                                     
========================================================================
  Minimum Requirements:                                                  
                                                                        
  IBM PC (or 100-percent compatible) Pentium-based machine                  
  75MHz, 16MB Memory                             
  VGA Video Adapter                                                     
  Hard Disk Drive (12 MB free space)                                 
  CD-ROM drive(not needed if downloading from the web)
  Mouse or Pointing Device
  Microsoft Windows 95/98/NT                             
                                                                        
========================================================================
 V. SOFTWARE INSTALLATION                                             
========================================================================
                                                                        
To install ZDS, perform the following steps:                      
                                                                        
    1. Insert the ZDS CD into your CD-ROM drive.              
    2. Follow the on-screen instructions.
                                                                        
    PROGRAM UNINSTALLATION:                                             
    -----------------------                                             
    Uninstaller facilities are created during the installation of ZDS.                                                                
                                                                        
    The uninstaller should be utilized when removing ZDS from your PC to 
    properly restore the Windows operating environment.                                                                   
========================================================================
 VI. ELECTRONIC INFORMATION SERVICES                                   
========================================================================
   If you experience any problems while operating this product or if you
   note any inaccuracies while reading the User's Manual, please consult
   the ZDS on-line help or your local ZiLOG representative for assistance.
   If local ZiLOG Assistance is not available, please fill out the Problem/
   Suggestion Report Form in the file "PROBLEM.TXT" located in the main 
   ZDS installation directory. Then register at the following URL:

   http://register.zilog.com/login.asp?login=supportlogin
 
   and paste the form into the technical support request.

   We welcome your suggestions!


========================================================================
 VII. REVISION HISTORY SUMMARY                                          
========================================================================
ZDS: 3.68 02-18-2002
-----------------------------------------------------------------------
1)New Features:
  ------------ 
  o none

2) Known Bugs Fixed:
   ----------------
  o Fixed C symbol watch window problem where modifying a pointer member
    of a structure crashed ZDS.
  o Fixed saving problem of the file type option, where file types were 
    not retained after switching the selection of file groups/file folders.
  o Fixed the rebuilding problem of web files upon starting debugger
  o Fixed the slow rebuild while in debug mode
  o Improved the update dependencies. A failed-reading file will be no 
    longer flagged recursively. If there is errors during file reading,
    dialog will appear and reports error at the end of updating dependencies.

ZDS: 3.67 12-14-2001
-----------------------------------------------------------------------
1)New Features:
  ------------ 
  o Added support for new Z8038200101ZCO evaluation board of Z80382 family.
    For memory configuration, please refer to evaluation board User manual.
  o Added initial settings for new Z8038200101ZCO.

2) Known Bugs Fixed:
   ----------------
   o For Z382, fixed the step-into problem where stepping into a release 
     library will take a long time or hang. The fix will stop PC at dissaembly 
     window and allow machine-instruction stepping.   

ZDS: 3.66 09-14-2001
-----------------------------------------------------------------------
1)New Features:
  ------------
  o Added Custom file types under Tools\Options for Web files and Other
    file types. The customized file type group will appear in type filter
    of Add New/Files dialog.
  o Automatically converted ZDIZPACK-EZ80 and eZ808 to ZDIZPAK-eZ80 and
    eZ80190 respectively.
  o Added online registration under Help Menu
  o Showed registration keys in Help\About.  
  
2) Known bugs fixed:
   ----------------
  o Enabled project Settings menu for Z380 target.
  o Fixed the step-into problem where stepping into a release library 
    will take a long time or hang. The fix will stop PC at dissaembly 
    window and allow machine-instruction stepping.
  o Fixed the uploading code memory to a .hex file.
  o Fixed the problem where restarting debugger always rebuilds the 
    projects after a web file was modified and built.

3) Precaution:
   ----------
  o When the register pair HL is used to access memory and matches 
    the lower byte of the breakpoint address,   your code does not run
    in real time. The delays vary depending on how many times this 
    situation occurs before reaching the actual breakpoint address. 
    This problem happens while the eZ80 device is in debug/ZDI mode and
    does not affect performance in actual applications. Check On-Line
    Help under Debugging Tips.

4) eZ80190 Kit Users Manual. Please refer to the CDROM copy of the Users
   Manual for latest updates.  The jumper settings in the CDROM pdf file
   is the correct version. 
   CDROM/eZ80190 Technical Documentation/eZ80190 Evaluation Board/eZ80
   Evaluation Board User Manual UM0113.pdf


ZDS: 3.65 BETA 4 08-15-2001
-----------------------------------------------------------------------
1)New Features:
  ------------
  o Added automatic Web-to-C file conversion for eZ80. If a eZ80 project
    includes web file(s)(.htm, .htlm, .jar, .gif, .jpg,.class), ZDS build/
    rebuild-all process will automatically convert the web file(s) to .c 
    file(s) before building the source files. For more information, please
    visit the one-line help.
  o Added support for Z86L825/L8256/L8257/L972/L973/L974.
 
2) Known bugs fixed:
   ----------------
  o Enabled project Settings menu for Z380 target.
 
ZDS: 3.65 BETA 3 07-10-2001
-----------------------------------------------------------------------
1)New Features:
  ------------
  o Added Insert, MoveUp, MoveDown button for listboxes under project\
    settings\linker. Please click on help button for more information
    on each linker page.
2) Known bugs fixed:
   ----------------
  o Disabled sorting of the linker listboxes under linker setting pages.
  o Fixed the problem in which adding a .c file to a project will give a
    "file is not a text" error message if my computer folder options
    are set to hide known the file types.
  o Removed unsupported evalboards: Z80S180EVAL and Z80S182EVAL
  o Fixed the problem where Z86E1xx code memory window is not displaying
    proper values of the memory.

ZDS: 3.65 BETA 2 06-18-2001
-----------------------------------------------------------------------
1)New Features:
  ------------
  o Added linker grouping command under project\settings\linker
  o Added linker noloading command under project\settings\linker
  o Added 'remove file from project' in FileView popup menu. User can
    right-mouse click a file from the FileView to remove a file.
  o Added 'Add new/existing file from project' in FileView popup menu. 
    User can right-mouse click on project names or 'Source File' folder 
    from the FileView to add a new/existing file.
  o Split eZ80 regiters AF and AF' into A,F,A' and F' in eZ80 standard
    register window.
  o Added eZ80190 device
  o Added eZ80 flashloader utilities under <ZDS Installation Directory>\
    utilities\eZ80\flash

2) Known Bugs Fixed:
   ----------------
  o Saved eZ80 initial settings after moving a previous project into
    a new location.
  o Automatically rebuilt when included libraries were updated/rebuilt.
  o Removed unsupported Z80S182EVAL.
  o Removed 'file is not a text file' error message when double-clicking 
    on 'Source Files' or Dependencies' in the FileView.
  o Disable 'Enable ZASM Compatible' under project\settings\assembler\
    preprocessor upon creating a new project is created. 

ZDS: 3.65 BETA 05-21-2001
-----------------------------------------------------------------------
1)New Features:
  ------------
  o Integrated with ZDS SR3 which supported Z183 code overlay.
  o Supported compiler settings by file for every family.
  o Added ADL mode bit under project/target/initial setting for eZ80.

  Z183 C Code Overlay Support
  ---------------------------
  o  Added 'Trace into MMU manager' option. This option can be selected 
     by right-mouse clicking in the editor. This option allows you  to 
     step into overlay manager.
  o  Stepinto/Stepout/Step over between 64K segments.

     Below are the steps to set up an overlay configuration for a file.

     a) Initialize default configuration for overlay:
        a.1) Under Project Settings\Compiler, select your project name in 
             source file list.
        a.2) Under Project Settings\Compiler\General,  select 'with overlay
             usage'.
        a.3) Click 'Set Default'

     b) Specify a section name for a file which will be located beyond 64K
        b.1) Under Project Settings\Compiler, select 'Code Generation' in category.
        b.2) Select a file from source file list.
        b.3) Enter a section name for the file in ".TEXT"
        b.4) Repeat step 2b to 2d for other files which will be located beyond 64K

     c) Configure Linker Settings:
        c.1) From step 1b, the following linker settings are configured as default:
             ROM : 0 to 1FFFF under Project Setting\Linker\Memory Map
             .CBAR = %82 under under Project Setting\Linker\Symbol Definition
             .TOS = %0fffe under Project Setting\Linker\Symbol Definition
             .ovlhf = 38h  under Project Setting\Linker\Locating
             Enable Overlay Support is checked under Project Setting\Linker\Overlay
             Areas. 
             Bank vector = 38h under Project Setting\Linker\Overlay Areas, 
             ovbank: 2000h to 7FFFh under Project Setting\Linker\Overlay Areas, 

        c.2) Now, the remaining task is to specify section name for each overlay
             file under Project Setting\Linker\Overlays. Please see overlay sample
             for reference.
             The sample is located under sample\80183\C Sample\overlay.

     d) Configure starting Program Counter:
        d.1) Under Project\Target\Initial Settings, set PC to 0AB ( this is where
             the .startup section begins. If you change the startup file, please
            refer to the generated .map file and enter the right value for PC).
  
2) Known Bugs fixed
   ----------------
  o Allowed to back up an incompatible-format version of a previous project.
  o Added progress indicators for downloading hex file/fill memory.
  o Fixed the hexfile uploading to save the correct hex format.
  o Remembered the file type/path selection from open/add/new file dialog.
  o Remembered the .bss, .data from Z183 compiler code generation page.
  o Changed build menu, 'assembly/compile' to 'assemble/compile'.
  o Added 'Add All' button for 'Add file' dialog. The 'Add All' will add
    all files with the selected type.
  o Changed the forward slash of compiler include path to backward slash.
    With the forward slash, the compiler can not find nested include
    files.
  o Saved Bank Vector in the linker overlay areas so that when changing
    linker category, it will not lose the current bank vector.
  o Changed the communication error handler so that when communication 
    timeouts, it will not repeatedly flag communication error messages.
  o Flagged the h/w reset message when s/w cannot reset the eZ80/183 eval
    board.

3) Limitations:
   ------------
   - Step into C standard-library functions such as printf and etc.. will take
     a period of time.
   - If the include path contains a hyphen, the path will be truncated after
     the project was loaded. This will be fixed in the 3.65 release.

ZDS: 3.64 BETA 3  03-30-2001
-----------------------------------------------------------------------

1) Installation directory has been restructured as below:

   <ZDS installation directory>
                 |____ bsc            : contains firmware (.bsc files)
                 |      |___80183
                 |      |___89C00
                 |      |___eZ80
                 |      |___Z8
                 |      |___Z8+
                 |      |___80382
		 |
                 |____ Hardware
                 |      |___ Z89190
                 |      |___ Z8 Motherboard BootRom
                 |      |___ ZPACK BootROM
		 |
                 |____ Include         : Target Include files
                 |____ samples         : Target sample files

   
2) Known bugs fixed
   -----------------
   o Fixed Z80183 simulator to support single-stepping over halt 
     instruction.
   o Fixed L99 counter/timer register window to display correct values.
   o Saved the linker suppress Warnings/banners and output options upon
     exiting a project.
   o Saved 'Generate debugging options of compiler setting' upon exiting
     a project.
   o Fixed assembly watch window to display word/long value correctly
     for eZ80, Z80183, and Z80382.
   o Fixed the bug where breakpoints were placed at the start of each
     C function when a breakpoint was found on an invalid debug line.
   o Fixed the crash when placing a variable of enumeration type into
     the C Symbol watch window.
   o Added linker command, 'Locating' under linker settings. The locate
     command allows to locate a section at a specified absolute address.
   o Saved changes for asm/C/default type under tool settings.
   o Flagged a warning when saving a "read-only" project.
   o Flagged a warning when saving a "read-only" file.
   o Added the progress indicator when downloading a hex file.
   o Removed Z86E142/E143/E144/E145 from Z86E3600ZEM.
   o Added Z86E142/E143/E144/E145 to Z86E3500ZEM.
   o Added data memory viewer for Z86E142/E143/E144/E145.
   o Fixed the problem where the global variables were displayed as unknown 
     variables.
   o Fixed the problem where ZDS crashed after stopping running eZ80 OSTK
     and opening the C Watch window.
   o Fixed the crash problem when opening the disassembly window under
     window 98SE.
   o Added file type selection, "*.asm, *.s, *.c" under add file dialog.
   o Automatically linked to the compiler include path if the compiler
     is found under registry or in the <ZDS path>\bin.
   o Fixed hex file downloading issue.

ZDS: 3.64 BETA 2  01-19-2001
-----------------------------------------------------------------------
   o Added -Zp1 8bit alignmnent for Z380 Support under Projects\Settings\
     Compiler\Code Generation.
   o Fixed "failed reading file..." when opening a project form "Recent
     Projects" List or when opening a project and adding a new file to
     the project.
   o Fixed problem where dependencies list does not showed up sometimnes.
   o Allowed multiple selection when selecting the library files for linker
     settings.
   o Added 'clipboard copy' from output window. To copy the contents of
     the output window to the clipboard, use right-mouse click and select
     'copy'.

ZDS: 3.64 BETA 1  12-04-2000
-----------------------------------------------------------------------
   1) eZ80 Support
      ------------
      a) Features:
        ---------
        o Program trace - step in, step out, step over, Go, Reset + Go, 
          Run To Cursor, Download Code and Reset.
        o Up to four break points can be set in the user Applications.
        o C symbol watch Window
        o Call chain Stack window
        o Disassembly window
        o Source navigation at file and function level
        o Code memory window
        o Standard Register window
        o I/O Registers window
        o External I/O Memory window
        o C compiler settings support
        o Initial Settings under Project Target Dialog. This setting
          allows user to initialize the eZ80 Control/Chip Select Registers. 
          These values will be sent to eval board right after reset.
        o Simulator support.      
	b)Limitations:
        -----------
        o Please see errata document shipped with the kits.
      
   2) Known Bug Fixed
      --------------
      o Fixed hanging problem after downloading or resetting Z183 code.
      o Fixed fonts problem of debug windows when ZDS is running with
        windows versions of international language.
      o Changed linker to support project nanme and source file name
        with character from the expanded ASCII code table.     
      o Fixed Z382 communication problems when a breakpoint is encountered.
      o Fixed Z382 code downloading problem in version 3.62.
      o Added PC Highlight Bar for Disassembly Window.
      o Added support of downloading hexfile beyond 64K for Z183 and eZ80.

ZDS: 3.63 Release 09-20-2000
-----------------------------------------------------------------------
   o Upgraded ZPROG firmware(ZIP.BIN) from ver. 1.10 to ver. 1.13
   o Upgraded ZIPFLASH.BSC from ver 1.03 to 1.04
   o Added automatic downloading of hex file to code memory for OTP ONLY
     Project.
   o For ICSP, during connection, .ld file will be automatically download
     after building modified sources.
   o Added downdoading progress indicator when downloading a hex or binary
     file.
   o Fixed the Z8 simulator bug where da instruction loses the carry flag.
   
ZDS: 3.62 Release 08-04-2000
-----------------------------------------------------------------------
   o Added ICSP support for Z86E122/E123/E124/E125/E126.
   o Fixed problem where closing all files does not save modified files.
   o Changed the name convention of L99 OTP option bits as shown:
     - OSC Feedback to 32kHz Oscillation
     - WDT Enable to Permanent WDT Enable
     - Fixed RC Option bit programming for Z86L9900100ZEM.
   o Production Release for Z8E13x ICSP and Z86L9900100ZEM.

ZDS: 3.62b
-----------------------------------------------------------------------
   o Alpha Release for Z183 C Source Level Debugger.

     Known Bugs:
     ----------
       1. When the variable value is in the register at any point of
          execution, the editing of the variable value in the C symbol
          watch window does not have any effect on the further execution
          of the program.
       2. When simulator perform multiplication or division of integer 
          values or of floating points, the system hangs
       3. In case of floating point operations like substraction, 
          simulator does not give proper result.
       4. Recursive functions is not working properly with simulator.
       5. Step out is not working properly with simulator.
       6. Fixed the editor problem.
       7. Fixed the problem where firmware change cpu flag register 
          after getting memory.
     
     Limitation:
     ----------
       1. Since the object file has no information about which register
          of a pair holds a byte valued variable, both the registers are
          displayed.
       2. The user is able to click on the Step-in, step-over icon even
          when the current action is happening. This causes a break in
          execution.
       3. In the case of global and static variables, the previous value
          of the Variable is preserved, during the next re-execution of
          the program unless the program is explicitly downloaded.

   o Added Z86E122/E123/E124/E125 support for ICSP (Z8/Z8+ serial in-
     circuit programmer)
   o Fixed option bits display for Z8PE013.
   o Included ICSP f/w version 1.12

ZDS: 3.62a 
-----------------------------------------------------------------------
   o Fixed problem where closing all files does not save modified files.
   o Added support for ICSP with Z86E126, Z8PE013/PE014/E014/E015/ 
     E016/E017
   o Enabled Reset button for ICSP so that reset will automatically 
     connect and download file to emulator.
   o Changed the name of Z86L99 firmware file from Z86L98.bsc to 
     Z86L99.bsc. Restored L98 firwmware from version 3.5 for Z86L9800ZEM.
 
ZDS: 3.61 Release 07-21-2000
-----------------------------------------------------------------------
   o Added support for ICSP (In-circuit Serial Programming) with
     Z86E132/E133/E134/E135/E136/E142/E143/E144/E145/E146.
   o Added support for Z86L9900100ZEM

ZDS: 3.5 Release 04-28-2000
------------------------------------------------------------------------
   1) New Features:      
      ============
      a) Languages:
         ---------

         Z380 C Compiler
         -----------------
	 o Added C compiler settings support
         o Added C Source Level Support (CSLD)

      b) New emulators supported:
         -----------------------
         o Added support for Z80382 Eval Board including Assembly and 
           C Source Level Debugging
         **** When using the eval board, users need to upgrade the 
              boot rom. The boot rom file, "382_zds.hex" can be found 
              in ZDS installation directory. It also contains a  
              Z382readme.txt, which explains how to use eval board with 
              the new boot rom. 	   

   2)  Important Notes:      
       ===============
       o For the Z8+ the E001 built in registers needed are included in 
         ...\Samples\Z8e00x\Ice_test\z8e001.inc
       o If you intend to run ZDS on Windows 95 you will also need to 
         update your windows socket files.  Otherwise you will receive 
         error messages indicating that some files are missing, 
         specifically "ws2_32.dll". The update resolves a number of 
         Winsock2 and TCP/IP stack issues. It has been released since the 
         Microsoft Windows 95 Service Pack 1 (Sept 10, 1996) and is 
         available for download on Microsoft's web page. 
         
         NOTE: This download is not intended for use on computers running 
         Windows 98. 
       o If Windows starts dial-up networking when ZDS is executed, then 
         go to the control panel and select internet options. Click on the 
         connection TAB and choose "never dial a connection". Dial-up 
         networking will automatically run when starting an application 
         that uses Winsock and is configured to use dial-up networking 
         when connecting to the Internet. This problem should only occur 
         when you select your target to be a Z8/Z8+ simulator, since 
         z8/z8+ simulator use Winsock services. 
       o You must reset you default linker settings for the C-compiler 
         whenever you choose another emulator or target from the Project 
         dialog box. To set the default linker settings for the C-compiler 
         select Settings from the Project file menu. Click on the C-
         compiler tab and select General from the C-compiler settings pop-
         up menu. Click the Set Default button.             
           
   3)  Known Bugs fixed:
       ================
       o  #include file delimited by <> do not get updated in the 
          dependency list
       o  Value column size for C symbol watch window does not get saved 
          in the project save
       o  CSLD with simulator is slow
       o  Linker Setting, Object/Library modules, Pathnames containing a 
          space character is not being saved in a project save
       o  Color coding for char in a c file should be case sensitive
       o  Rom check sum and rom byte values always 0 after download
       o  Intermittent reset when debugging
       o  No external memory window for 32302
       o  Remove EPROM Protect option for D73/D86/D93
       o  Transform relative option (-J) automatically sent to assembler 
          for a c file
       o  Opening Z8's reaction sample gives error message that no target 
          is selected
       o  During Debugging if a value in the C symbol watch window is 
          changed, the value should stay red.   
       o  No Expanded 4,5,6 for Z90251/255 
       o  Initialization files (Z8L.ini and Z8S.ini) did not have the 
          default file lists required for App Wizard
 
   4)  Precautions:
       ===========     
       o  Only 2 breakpoints are allowed with Z183 with ZPAK ZDI
       o  Only 6 breakpoints are allowed with Z382 Evaluation board
       o  While loop with constant condition generates no debug info
       o  C Compiler .Lib files are not displayed in source file list 
          after selecting them from App wizard window.
       o  When stepping through multiple files, the yellow pointer stays 
          in the opened files.
       o  Cannot edit values for variables in the C Symbol Watch window 

ZDS: 3.5 Beta 02-11-2000
------------------------------------------------------------------------
   1) New Features:      
      ============
      a) Languages:

         Z8/Z8+ C Compiler
         -----------------
	 o Added C Symbol Watch Window
         o Added C Call Stack Window
         o Added Step Out Command used to step out of a C function
         o Added C Function View. The function view tab can been seen
           next to file view tab of the workspace window. The function
           view tab allows to view C functions. Clicking on a function
           name will take you to the corresponding function in editor.

         Important Notes:
         ----------------
	 o The Initialization files (Z8L.ini and Z8s.ini) do not have
           the default file lists required for App Wizard. When using 
           App Wizard, it requires that users copy those files from ZDS
           directory to <C compiler directory>\config.

         o For Z8Plus, it requires that users manually copy Z8Plusinit.s
           from ZDS directory to <C compiler directory>\lib.
	

      b) Simulators:
          ----------
         o ZDS now supports Z8/Z8+ simulator. The simulator can be 
           selected under Project\Target\Emulator.

         o For windows 95 operating systems, users may need to update 
           window sockets. The update package can be obtained from 
           Microsoft website.

      c) New emulators supported:
         -----------------------
         o Added support for Z80S183 Eval board with ZDI23200ZPK including
           intial settings under project\target.

      d) Assembler changes:
         -----------------
         o Z8Plus pre-defined register names will be no longer supported.
           This will prevent from updating the assembler for everytime 
           a new register name is added. The register names are now 
           defined in an include file, "Z8e001.inc" under <ZDS directoryL>
           \include\Z8E001. Users can take this file and include in the 
           source codes by using ".include" directive.	            
           
   2)  Known Bugs fixed:
       ----------------
       o  Fixed problem that project with .lib files always got rebuilt 
          after performing Reset/Go.
 
   3)  Precautions:
       -----------     
       o  Only 2 breakpoints are allowed with Z183
       o  #include file delimited by <> do not get updated in the 
          dependency list
       o  Value column size for C symbol watch window does not get saved 
          in the project save
       o  While loop with constant condition generates no debug info
       o  CSLD with simulator is slow
       o  .Lib files are not displayed in source file list after selecting 
          them from App wizard window.
       o  When stepping through multiple files, the yellow pointer stays 
          in the opened files.

ZDS: 3.01 Release 11-11-99
------------------------------------------------------------------------
   o Removed automatic link of .asm extension to ZDS.

ZDS: 3.00 Release 11-05-99
------------------------------------------------------------------------
   1) New Features
      ------------
      a) Language
         --------

         Z380 C Compiler
         ---------------
         o Added Code Generation property page which can be viewed from
           Project/Settings/C-Compiler/Category. The Code generation 
           allows user to specify uninitialized /initialized/text section 
           name and to select boundary alignment.
         o Changed the Layout of Optimization Property page under Project/
           Settings/C Compiler.

         Z89C00 C Compiler
         -----------------
         o Changed the Layout of Optimization Property page under Project/
           Settings/C Compiler.
          
         Z8 C Compiler
         -------------
         o Added Warnings property page which can be viewed from Project/
           Settings/C Compiler/Category. 
         o Added new switch, "Enable ZiLOG Language Extension" in General
           property page under Project/Settings/C Compiler/Category. 
          
         IMPORTANT NOTES:
         ----------------
           Installation:
           ------------                    
           FOR NEW C COMPILER INSTALLATIONS, USER NO LONGER NEEDS TO COPY 
           THE COMPILER's DLLs (Z380.DLL, Z8.DLL, AND/OR Z3xx.DLL) INTO 
           ZDS DIRECTORY. The compiler installation will set the compiler 
           path in the registry and ZDS 3.00 Release or later will look 
           for the path and load the corresponding DLL from that path. 
           This change is effective for the following compiler versions:
         
           +-----------------+-------------------+
           | Compilers       + Versions          |
           +-----------------+-------------------+
           | Z380            | I0.00 or later    |      
           +-----------------+-------------------+
           | Z3xx            | B0.00 or later    |
           +-----------------+-------------------+
           | Z8              | C1.00 or later    |                   
           +-----------------+-------------------+
   
           Earlier compiler versions require the user to explicitly 
           copy the compilers'DLLs to ZDS installation directory.

           Debugging:
           ----------
           o To use the debugger's capabilities, user needs to turn off 
             compiler optimization.

           o This version does not fully support C Source Level Debugging.
             Debugger capabilities for C Code are limited to Step into,
             Step over, Run to Cursor, and breakpoints. Next version,
             coming soon, will include full debug support. 
             
           File extensions:
           --------------
           ZDS differentiates between assembly and C source files by 
           extensions. The extensions are shown below:

            C Code when:
               .C
               .CPP
               .CXX
               .h (header, can be changed in tools/options to be 
                   considered assembly)
         
            Assembly code when:
               .ASM
               .S
               .inc (header)
                  
      b) Environment
         -----------
         o When closing a project ZDS automatically stops the debugger
           without having the user to do so.

      c) Editor Enhancement
         ------------------
         o Added color Option to treat .h file as either ASM or C file 
           under Editor settings.
         o Added right-mouse click popup menu for Cut/Copy/paste/Toggle
           bookmark/Toggle breakpoint.

      d) OTP
         ---
         o Removed the use of Apply button in OTP dialog. Changes will 
           take into effect right after device/Option/Serial selection
   
      e) HELP   
         ----
         o Added Hot-key F1 for Help

   2) Known Bugs fixed
      ----------------
      o Fixed Chroma Color problem where directives starting with period
        were not color-highlighted.
      o Fixed Single-step degradation in performance compared to ZDS 2.12.
      o Fixed unsaved watch variables after closing project.
      o Fixed Communication Error problem with RESET+GO..
      o Fixed the problem where 'Find in Files' does not work with *.*.
      o Fixed the RFILE Range for Z8E000 to 32K instead of 64K.

   3) Precautions
      -----------
      o For Windows NT, ZDS requires at least service pack 4 or above.    
      o If target is changed and project is not rebuilt, ZDS will load
        the old .ld file when downloading code or reset.

ZDS: 3.00 Beta 1.2 10-11-99
------------------------------------------------------------------------
      o Added OTP Programming Only Support - This is a new project type 
        which allows the user to perform OTP operations without having the 
        source code. The user still needs to create a project but can add 
        a single(hex, ihx, ld or bin) file. The new project type will not 
        allow debugging operations. However, the user can download code, 
        view memory code and perform OTP operations, .etc session. The 
        project can be reopened with all previously saved configurations 
        if the project has been created and saved with OTP Programming 
        Only.

ZDS: 3.00 Beta 1 09-02-99
------------------------------------------------------------------------
   1) New Features
      ------------
      a) Language 
	 --------
         o C language support for 380, Z8 and Z3xx families. Z380.dll, 
           Z8.dll and/or Z3xx.dll are needed. These DLL's need to be 
           requested from ZiLOG for the Compiler License. These DLLs need 
           to be in the same directory where ZDS.exe resides. Compiler 
           switches can be set in menu Project/Settings/Compiler. 

         o Can enable archiver support either when creating a project or 
           using the Target selection dialog box, which allows the user to 
           select Application or Library. Archiver switches in Project 
           /Settings/Archiver

      b) Environment
	 -----------         
         o Workspace manager. Debug and edit windows size and position 
           (docked or floated) are now saved with the project. The 
           information is saved on disk and sometimes may be slow in 
           saving. The user can turn this option on/off in 
           Tools/Options/Workspace. Double click on the .zws project file 
           to launch ZDS and open the project.

      c) Debug
	 ----- 
         o Pad Memory is included when downloading an application. Pad 
           options can be accessed by selecting Project/Settings/Debug. 
           Check Sum and Byte Count is displayed after downloading a file. 
           Z8 download: .dat file is downloaded into Register File space 
           Option. New Upload function allows the user to upload memory in 
           either hex or binary file. Z183/ZDI is now supported.
      
      d) OTP
	 ---
         o Option Buttons are included in the OTP dialog box. 

      e) Editor enhancement
 	 ------------------        
         o Print Preview
         o Print Selection
         o C file coloring
         o User customizable coloring. Menu Tools/Options/Editor
         o User customizable fonts. Menu Tools/Options/Editor
         o Drag and drop of text
         o Ability to change tabs to spaces and view tabs in the editor 
           window
         o Wrap around find text
         o Bookmark support
         o Edit window split support

   2) Known Bugs fixed
      ----------------
      o Z8 register window: the PC high byte can now be changed manually.
      o Fixed the OTP Programming options.

ZDS: 2.12 07-20-99
------------------------------------------------------------------------
     o Changed Z8ICE000ZEM to Z8ICE00xZEM in the Emulator Selection.
     o Automatic Reads Emulator when  opening  the OTP programming
       options dialog box.
     o Added support for option bits Z8PE00x.
     o Changed the ZDS Project Settings so that ZDS will not open the 
       Debug windows if  the  latest  version of ZDS is added with the new 
       memory windows.
     o Installation version for Z9036900ZEM H/W beta.
     o Added Z8plus demo sample files.
     o Fixed the problem of  downloading hex files to Z8 data memory 
       (Z86L98).
     o Fixed DSP OTP PROGRAMMING regarding CHECKSUM when device has WORD
       WORD checksum utility.
     o Fixed Z183 Communication problem when downloading HEX file into
       the code memory.                       
     o Updated database for Z8ICE000ZEM BSC downloading & Z8P002 device.
     o Added support for Z86L9800ZEM/Z86D93
     o Fixed support for Z86L9800ZEM/Z86L89 Port 0 selection
     o Fixed support for Z86L9800ZEM/Z86L82 from 24K to 4K ROM size
     o Added support for Z9036900ZEM Flash Download
     o Fixed 24K ROM sizing for ICEBOX which has C50/C12 ICE chips
     o Fixed Object File downloading problem

ZDS: A2.11
------------------------------------------------------------------------
     o Fixed Z9036900ZEM Interrupt Vectors
     o Added Support for Z86L9800ZEM (H/W still for Alpha Testing)
     o Added Support for Z86C3600ZEM (H/W still for Alpha Testing)
     o Added Support for Z8ICE000ZEM for firmware update(BSC file)
     o Updated Z90251 OTP Programming Support for CGROM decoding
     o Files changes from 2.11 to A2.11 :
     -------------------------------------------------------------------
       ZDS.EXE...updated
       ZMA32.DLL...updated
       Z8EM_259.BSC...updated

ZDS: 2.11                                                           
------------------------------------------------------------------------
     o Fixed relative jumps(JR/JP) optimization for Z8/Z8+
     o Files changes from 2.10 to 2.11 :
     -------------------------------------------------------------------
       ZDS.EXE...updated  
       ZMA32.DLL...updated

ZDS: 2.10                                                           
------------------------------------------------------------------------
     o Added porting option for ZASM to ZMASM
     o ZMASM updates/addresses the following:
       - Z8plus wrap-around "vector"
       - Alignment directives
       - Support relative jumps between sections for the Z8/Z8+
- Ways to convert Z8/Z8+ 8-bit register addresses to 4-bit 
   addresses.
     o New switch in Assembly settings.
     o Disassembly Pointer enhancement
     o Fixed hidden breakpoints set-up from old Project Files.
     o Added Z9025900ZEM Support 
     o Added Z87L0200ZEM Support         
     o Added Z9036900ZEM Support         
     o Added ZDS/ZDI23200ZPK(Z183) Support (H/W not released yet).
     o Showed Project Directory path in project view.
     o Fixed mis-typed register name P13 instead of R13.
     o Added Z8/Z8plus Timer/Counter, Ports and Working Register Window               
     o Fixed the Fill External Data Memory option when used with more than 85H bytes.
     o External Data Memory Boundary address space (contiguous from ROM)
     o New ZMASM directives are supported in the Editor(color code).           
     o Added Color support for the .ERROR directive.
     o Assembler(M2.11), Linker(K2.11) and Disassembler updates.
     o PC pointer is now displayed in disassembly window.
     o Updated Z9034900ZEM OTP Programming algorithim? for address 0000H 
       and 0001H. Multiple writes of FFFFH prior to actual data writes.
     o Updated Z86E44/E86 EPROM Programming with changes in EOS for /OE.
     o Fixed Z86E40 OTP programming range of up to 0400H.
     o Fixed Z893230xZEM breakpoint problem.
     o Streamlined the creation of debug windows and menu selection through
       database entries.
     o Files changes from 2.00 to 2.10 :
     -------------------------------------------------------------------
       ZDS.EXE...updated  
       ZILOGMCU.ZLG...updated
       SERIAL32.DLL...updated
       ZDZ180.DLL...updated
       ZDZ3400.DLL...updated
       ZDZ8.DLL...updated
       ZDZ89C00.DLL...updated
       ZLD32.DLL...updated
       ZMA32.DLL...updated
       ZMA32Z180.DLL.... updated
       ZMA32Z380.DLL.... updated
       ZMA32Z462.DLL.... updated
       ZMA32Z8.DLL...updated
       ZMA32ZC00.DLL.... updated
       ZMA32ZC50.DLL.... updated
       Z8EM_259.BSC...updated 
       Z8EM_349.BSC...updated
       Z8EM_CCP.BSC...updated
       Z8EM_C50.BSC...updated
       Z8EM_C15.BSC...updated
       Z8EM_K15.BSC...updated
       Z8EM_183.BSC...added  
       Z8EM_259.BSC...added  
       Z8EM_369.BSC...added  
       Z8EM_L02.BSC...added  
       ZPK232.HEX...added  

--------------------------------------------------------------
ZDS: Rel. 2.00                                                          
   o Please see Precautions and Limitations "ZDSPNL.TXT" file.      

ZDS: Rel. 2.00 Beta 2
   o Added Debug/Emulation support for Z8/Z8Plus/Z89C00                 
   o See P_AND_L.TXT for additional information                         
                                                                        
ZDS: Rel. F2.00 Beta 2                                                  
----------------------                                                  
   o Fix lap-top sensitivity issues.                                    
                                                                        
ZDS: Rel. 2.00 Beta 1                                                   
---------------------                                                   
   o Added Debug/Emulation support for Z9034900ZEM/9035900ZEM           
   o Added Debug/Emulation support for Z8E52000ZEM                      
   o Please see Beta Release Notes "BETAREL.DOC"                        
                                                                        
ZDS: Rel 1.00 (with ZMASM)                                              
-------------                                                           
   o First Production Release.                                          
                                                                        
ZMASM: Rel. 2.10                                                        
----------------                                                        
   o Fixed problem when exponent of zero is used.                       
   o Fixed Z8 relocatable register to register addressing.              
   o Fixed Z8 relative jump in absolute mode.                           
   o Fixed Z89C00 structure assembly with >= and < operators.           
   o Added Z180/Z380 Support                                            
                                                                        
ZMASM: Rel. 2.00                                                        
----------------                                                        
   o First Production Release.                                          
                                                                        
========================================================================
  END                                                                   
========================================================================                 
