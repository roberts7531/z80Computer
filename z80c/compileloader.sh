#/bin/bash
zcc +z80 -vn -O3 -startup=0 -clib=new test.c -o test -lm -create-app -Cz--ihex