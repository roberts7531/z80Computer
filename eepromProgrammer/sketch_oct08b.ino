//A0-A7 data
//8 - adata
//5-aclk
//4 /oe
//2 /we
//11/ce
void setup() {
  // put your setup code here, to run once:
  pinMode(8,OUTPUT);
  pinMode(5,OUTPUT);
  pinMode(11,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(2,OUTPUT);
  digitalWrite(4,HIGH);
  digitalWrite(2,HIGH);
  digitalWrite(11,HIGH);
  Serial.begin(115200);
  
}

byte readInData(short addr){
  shiftOut(8,5,MSBFIRST,addr>>8);
  shiftOut(8,5,MSBFIRST,addr&0b11111111);
    digitalWrite(11,LOW);

  pinMode(A0,INPUT);
  pinMode(A1,INPUT);
  pinMode(A2,INPUT);
  pinMode(A3,INPUT);
  pinMode(A4,INPUT);
  pinMode(A5,INPUT);
  pinMode(12,INPUT);
  pinMode(13,INPUT);

  digitalWrite(2,LOW);
  delay(5);
  byte data;
  data = digitalRead(13);
  data = (data <<1)|digitalRead(12);
  data = (data <<1)|digitalRead(A5);
  data = (data <<1)|digitalRead(A4);
  data = (data <<1)|digitalRead(A3);
  data = (data <<1)|digitalRead(A2);
  data = (data <<1)|digitalRead(A1);
  data = (data <<1)|digitalRead(A0);
  digitalWrite(2,HIGH);
  digitalWrite(11,HIGH);
  return data;
  }

void writeData(short addr, byte data){
  
shiftOut(8,5,MSBFIRST,addr>>8);
  shiftOut(8,5,MSBFIRST,addr&0b11111111);
    

      digitalWrite(11,LOW);

  pinMode(A0,OUTPUT);
  pinMode(A1,OUTPUT);
  pinMode(A2,OUTPUT);
  pinMode(A3,OUTPUT);
  pinMode(A4,OUTPUT);
  pinMode(A5,OUTPUT);
  pinMode(12,OUTPUT);
  pinMode(13,OUTPUT);
  digitalWrite(A0,data&0b1);
  digitalWrite(A1,data&0b10);
  digitalWrite(A2,data&0b100);
  digitalWrite(A3,data&0b1000);
  digitalWrite(A4,data&0b10000);
  digitalWrite(A5,data&0b100000);
  digitalWrite(12,data&0b1000000);
  digitalWrite(13,data&0b10000000);
  digitalWrite(4,LOW);
  digitalWrite(4,HIGH);
  delay(5);
      digitalWrite(11,HIGH);

  }
void loop() {
  
  Serial.print('R');
  while(true){
    if(Serial.available()>0){
      short in=Serial.read();
      if(in=='r'){
        short addr = Serial.parseInt();
        Serial.print(readInData(addr),DEC);
        Serial.println();
        break;
        }
      if(in=='w'){
        short addr = Serial.parseInt();
        Serial.read();
        byte data = Serial.parseInt();
        writeData(addr,data);
        Serial.println();
        break;
        }
      }

  //delay(1000);
  // put your main code here, to run repeatedly:
  //if(firstRun){
  //      for (short i =0; i<(sizeof(data) / sizeof(data[0]));i++){
    //      writeData(i,data[i]);
      //    }
        
 
//    firstRun=true;
  //  }
  //Serial.println("start");
  //readInData(0);
//for(short i=0;i<25;i++){
  //Serial.println(readInData(i),HEX);
//}
    
  //while(true);

}}
