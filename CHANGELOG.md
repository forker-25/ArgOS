## Changelog
### p-a 1.0f
1. CPU Vendor Display Fix:  
 - Added a proper concatenation of the static label "CPU Vendor: " and the dynamically read vendor string from CPUID to display on the same line.  

2. Memory Info Integration:  
 - Incorporated BIOS calls (int 0x12 and int 0x15) to fetch real base and extended memory sizes instead of using static placeholder strings.  

and ETC...  
