#pragma output CRT_ORG_CODE = 0x2000



__sfr __at 0x04 LCD_COM;
__sfr __at 0x04 LCD_DAT;
int main(){
    
    
   LCD_COM = 0x1F;
   char x = LCD_COM;
   LCD_COM = 0x20;
   x = LCD_COM;
   unsigned char i =0;
   while(1){
       
       LCD_DAT = 0x55;
       for(short i=0;i<100;i++);
       x = LCD_DAT;
       i++;
       for(short i=0;i<255;i++);
       
   }
    while(1);
    
}