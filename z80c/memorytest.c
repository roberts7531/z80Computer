#pragma output CRT_ORG_CODE = 0x2000
#include <string.h>
#include "io.c"

char * teststart = (char *)0x21ff;
char asciib[3];

unsigned char current = 0x0;
int main(){
    asciib[2]=0x0;
    print("Starting memory test\r\n");
    for(unsigned short i = 0x8000;i<0xfe00;i++){
            
            unsigned char * test = (unsigned char *)i;
            *test = current;
            current++;
       
    }
    print("reading back values\r\n");
    current = 0x0;
    for(unsigned short i = 0x8000;i<0xfe00;i++){
            unsigned char * test = (unsigned char *)i;
            if(*test !=current){
                byteToAscii(i>>8,asciib);
                print(asciib);
                byteToAscii(i&0xff,asciib);
                print(asciib);
                print("\r\n");
                print("memory test fail\r\n");
                byteToAscii(*test,asciib);
                print(asciib);
                byteToAscii(current,asciib);
                print(asciib);
                print("\r\n"); 
                break;
            }
            current++;
       
    }
    print("end of test\n");
}