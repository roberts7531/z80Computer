__sfr __at 0x10 IDE_DATA;
__sfr __at 0x11 IDE_ERROR;
__sfr __at 0x12 IDE_SECT_COUNT;
__sfr __at 0x13 IDE_LBA0;
__sfr __at 0x14 IDE_LBA1;
__sfr __at 0x15 IDE_LBA2;
__sfr __at 0x16 IDE_LBA3;
__sfr __at 0x17 IDE_COMMAND_STATUS;



void waitForReady(){
    char asciib[3];
    while(1){
        unsigned char status = IDE_COMMAND_STATUS;
        if(status&0x40)break;
    }
}
void waitForDRQ(){
    char asciib[3];
    while(1){
        unsigned char status = IDE_COMMAND_STATUS; 
        if(status&0x08)break;
    }
}
void readSector(int lba,char*buffer){
    
    waitForReady();
    IDE_SECT_COUNT=1;
    IDE_LBA0=lba&0xff;
    IDE_LBA1=(lba>>8)&0xff;
    IDE_LBA2=(lba>>16)&0xff;
    IDE_LBA3=0xE5;
    IDE_COMMAND_STATUS = 0x20;
    waitForDRQ();
    for(short i=0;i<256;i++){
        waitForReady();
        *buffer = IDE_DATA;
        buffer++;
    }
    waitForReady();
    IDE_SECT_COUNT=1;
    IDE_LBA0=lba&0xff;
    IDE_LBA1=(lba>>8)&0xff;
    IDE_LBA2=(lba>>16)&0xff;
    IDE_LBA3=0xE6;
    IDE_COMMAND_STATUS = 0x20;
    waitForDRQ();
    for(short i=0;i<256;i++){
        waitForReady();
        *buffer = IDE_DATA;
        buffer++;
    }
    
}void writeSector(int lba,char*buffer){
    
    waitForReady();
    IDE_SECT_COUNT=1;
    IDE_LBA0=lba&0xff;
    IDE_LBA1=(lba>>8)&0xff;
    IDE_LBA2=(lba>>16)&0xff;
    IDE_LBA3=0xE5;
    IDE_COMMAND_STATUS = 0x30;
    waitForDRQ();
    for(short i=0;i<256;i++){
        waitForReady();
        IDE_DATA=*buffer;
        buffer++;
    }
    waitForReady();
    IDE_SECT_COUNT=1;
    IDE_LBA0=lba&0xff;
    IDE_LBA1=(lba>>8)&0xff;
    IDE_LBA2=(lba>>16)&0xff;
    IDE_LBA3=0xE6;
    IDE_COMMAND_STATUS = 0x30;
    waitForDRQ();
    for(short i=0;i<256;i++){
        waitForReady();
        IDE_DATA=*buffer;
        buffer++;
    }
    
}
