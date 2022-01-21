#pragma output CRT_ORG_CODE = 0x5000
#include <string.h>


void disableRom(){
    #asm
    out(0x00),a
    ret
    #endasm
}
void writeChar(char out){
    #asm
    pop hl
    pop de
    ld a,e
    rst 0x08
    push de
    push hl
    ret
    #endasm
}
void byteToAscii(unsigned char in,char * outp){
    char out;
    char high = in >>4;
    if(high<10)out = 48+high;
    else out = 65+high-10;
    *outp = out;
    outp++;
    out = 0;

    char low = in & 0b1111;
    if(low<10) out = 48+low;
    else out = 65+low-10;
    *outp = out;
    outp++;
    *outp = '\0';

}

void print(char* string){
   for(short i =0;i<strlen(string);i++){
        writeChar(string[i]);
    
    }
}
void disableRom() __stdc;

void exit(){
    #asm
    jp 0x0000
    #endasm
}

void memoryTest(){


}


void copyMemoryBlock(char* source,char*dest,short lenght){
    for(short i=0; i<lenght;i++){
        *dest = *source;
        dest++;
        source++;
    }

}


char * bootloader = (char *)0x0;
char * ram = (char *)0xd000;
char * message = (char *)0x03e6;
char asciib[2];

__sfr __at 0x10 IDE_DATA;
__sfr __at 0x11 IDE_ERROR;
__sfr __at 0x12 IDE_SECT_COUNT;
__sfr __at 0x13 IDE_LBA0;
__sfr __at 0x14 IDE_LBA1;
__sfr __at 0x15 IDE_LBA2;
__sfr __at 0x16 IDE_LBA3;
__sfr __at 0x17 IDE_COMMAND_STATUS;



int main()
{
    

    disableRom();
    copyMemoryBlock(ram,bootloader,(short)4000);
    
    exit();
}




