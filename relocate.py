##TODO allow args for relocating files
from intelhex import IntelHex
ih = IntelHex("rom.ihx")
ihl = IntelHex("cpmloader.hex")
bios = IntelHex("bios.hex")
ih2 = IntelHex()
for i in range(bios.minaddr(),bios.maxaddr()+1):
        ih2[0xd000+i] = bios[i]
for i in range(ih.minaddr(),ih.maxaddr()+1):
        ih2[0xd000+i] = ih[i]
for i in range(ihl.minaddr(),ihl.maxaddr()+1):
        ih2[0xd000+i] = ihl[i]

ih2.write_hex_file("romrel.hex")
