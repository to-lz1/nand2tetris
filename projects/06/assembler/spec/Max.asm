// excerpted from original Max.asm for testing
   @R0
   D=M              // D = first number
   @OUTPUT_FIRST
   D;JGT            // if D>0 (first is greater) goto output_first
(OUTPUT_FIRST)
   @R0
   D=M              // D = first number
(INFINITE_LOOP)
   @INFINITE_LOOP
   0;JMP            // infinite loop
