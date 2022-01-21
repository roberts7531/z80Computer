#pragma output CRT_ORG_CODE = 0xe4


#include <string.h>
#include <stdlib.h>
#include "ide.c"
#include "io.c"



void memdump(unsigned short start, unsigned short length){
    char asciib[3];
    char * startmem= (char*)start;
    byteToAscii(start>>8,asciib);
    print(asciib);
    byteToAscii(start&0xff,asciib);
    print(asciib);
    writeChar(' ');
    
    
    for(unsigned short i = 1;i<length+1;i++){
        byteToAscii(startmem[i-1],asciib);
        print(asciib);
        if(i%10==0){
            writeChar(' ');
            for(unsigned short j=i-10;j<i;j++){
                if(startmem[j-1]>31 &&startmem[j-1]<127){
                    writeChar(startmem[j-1]);
                }else writeChar(' ');
            }
            writeChar('\r');
            writeChar('\n');
            byteToAscii((start+i)>>8,asciib);
            print(asciib);
            byteToAscii((start+i)&0xff,asciib);
            print(asciib);
            writeChar(' ');
        }else
        writeChar(' ');
    }
}

char  command[50];
char * cmd = command;
char arg0[22];
char arg1[22];
char arg2[22];
char arg3[22];

const char message[] = "Hello world from new rom!\r\n";


void diskRead(int startlba,int location,int seccount){
    char*buffer = (char*)location;
    for(int i=0;i<seccount;i++){
        print("Reading sector\r\n");
        readSector(startlba+i,buffer+(512*i));
        print("Done\r\n");
    }
}
void diskWrite(int startlba,int location,int seccount){
    char*buffer = (char*)location;
    for(int i=0;i<seccount;i++){
        print("Writing sector\r\n");
        writeSector(startlba+i,buffer+(512*i));
        print("Done\r\n");
    }
}
void exec(unsigned short address){
    #asm
    pop de
    ret
    #endasm
}

void processCommand(char*command,char*arg1,char*arg2,char * arg3){
    if(strcmp(command,"MEMDUMP")==0){
        memdump(atoi(arg1),atoi(arg2)&0xFFFF); 
    }else if(strcmp(command,"READB")==0){
        diskRead(atoi(arg1),atoi(arg2),atoi(arg3));
    }else if(strcmp(command,"WRITEB")==0){
        diskWrite(atoi(arg1),atoi(arg2),atoi(arg3));
    }else if(strcmp(command,"EXEC")==0){
        exec(atoi(arg1));
    }else if(strcmp(command,"GOCPM")==0){
        exec(0x0d40);//cpmloaderaddr
        
    }

    else{
    print("unrecognised command\r\n");
    }
}







int main()
{
    char asciib[3];
    print(message);
    writeChar('|');
    while(1){
        
        char in = readChar();
        if(in=='\r'){
            memset(arg1,0,22);
            memset(arg2,0,22);
            memset(arg3,0,22);
            print("\r\n");
            char * pch;
            pch = strtok(command," ");
            strcpy(arg0,pch);
            pch = strtok(NULL," ");
            if(pch!=NULL){
            strcpy(arg1,pch);};
            
            pch = strtok(NULL," ");
            if(pch!=NULL){
            strcpy(arg2,pch);};
            pch = strtok(NULL," ");
            if(pch!=NULL){
            strcpy(arg3,pch);};

            processCommand(arg0,arg1,arg2,arg3);
            cmd=command;
            memset(command,0,50);
            writeChar('|');
            }
        else{
            if(cmd<command+50){
                
                if(in ==8){
                    if(cmd>command){
                        writeChar(in);
                    cmd--;
                    *cmd = 0;
                    }else{
                        writeChar(0x07);
                    }
                }else{
                    writeChar(in);
                *cmd = in;
                cmd++;}
            }
        }
    }
    
    
}
