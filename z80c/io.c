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
char readChar(){
    #asm
    rst 0x10
    ld l,a
    ret
    #endasm
}
void writeChar(char out) __stdc;
char readChar() __stdc;
void print(char* string){
   for(short i =0;i<strlen(string);i++){
        writeChar(string[i]);
    
    }
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
void leave(){
    #asm
    jp 0x0000
    #endasm
}