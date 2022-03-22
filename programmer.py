##TODO add Read feature and command line args
import serial
from intelhex import IntelHex
ser = serial.Serial('/dev/cu.usbserial-AL016U20', 115200)
global outstr
outstr = ""
global outcnt
outcnt = 0
def readByte(address):
    ser.write(("r"+str(address)).encode("ascii"))
    retint =int(ser.readline().decode("ascii"))
    while(True):
        if(ser.read().decode("ascii")=='R'):
            break
    return retint

def writeByte(data,address):
    global outcnt
    global outstr
    if(outcnt==7):
        ser.write(outstr.encode("ascii"))
        while(True):
            if(ser.read().decode("ascii")=='R'):
                outcnt -= 1
            if(outcnt==0):
                outstr = ""
                break;    
    outstr = outstr + ("w"+str(address)+"d"+str(data))
    outcnt +=1

if(ser.read()==b'R'):

    ih = IntelHex("MONITOR2.HEX")
    for i in range(ih.minaddr(),ih.maxaddr()+1):
        
        print(str(i) +" out of "+ str(ih.maxaddr()) +" "+hex(ih[i]))
        writeByte(ih[i],i)
    outcnt = 7
    writeByte(0,64000)
    #print(readByte(0))




