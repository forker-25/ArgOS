void crash_main() {
    char *video_mem = (char*)0xB8000;
    char *ram_ptr = (char*)0x2000;
    volatile int i, j;
    
    for(i = 0; i < 100000; i++) {
        for(j = 0; j < 8000; j++) {
            if(j < 4000) {
                video_mem[j] = 'X' + (i % 26);
                video_mem[j+1] = 0x40 + (i % 8);
            }
        }
        
        for(j = 0; j < 4000; j++) {
            ram_ptr[j] = 0xAA + (i % 256);
        }
        
        ram_ptr += 500;
        if((int)ram_ptr > 0xA0000) {
            ram_ptr = (char*)0x2000;
        }
        
        if(i % 10000 == 0) {
            for(j = 0; j < 1000000; j++) {
                asm("nop");
            }
        }
    }
}

void _start() {
    crash_main();
    asm("ret");
}
