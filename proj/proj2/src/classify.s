.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    li t0 5
    bne a0 t0 arguments_error
    
    # Prologue
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)
    # store
    mv s0 a1
    mv s1 a2
    
    # Read pretrained m0
        
        # malloc 
        li a0 4 
        jal ra malloc
        mv s2 a0 # s2 is the pointer for the memeory of row
        
        # check malloc error 
        beq s2 x0 malloc_error
        
        # malloc 
        li a0 4 
        jal ra malloc
        mv s3 a0 # s3 is the pointer for the memeory of col
        
        # check malloc error 
        beq s3 x0 malloc_error
        
    lw a0 4(s0)
    mv a1 s2
    mv a2 s3
    jal ra read_matrix
    mv s4 a0 # s4 store the m0 address
    
    # Read pretrained m1
        # malloc 
        li a0 4 
        jal ra malloc
        mv s5 a0 # s5 is the pointer for the memeory of row
        
        # check malloc error 
        beq s5 x0 malloc_error
        
        # malloc 
        li a0 4 
        jal ra malloc
        mv s6 a0 # s6 is the pointer for the memeory of col
        
        # check malloc error 
        beq s6 x0 malloc_error
        
        
    lw a0 8(s0)
    mv a1 s5
    mv a2 s6
    jal ra read_matrix
    mv s7 a0 # s7 store the m0 address

    # Read input matrix
        # malloc 
        li a0 4 
        jal ra malloc
        mv s8 a0 # s8 is the pointer for the memeory of row
        
        # check malloc error 
        beq s8 x0 malloc_error
        
        # malloc 
        li a0 4 
        jal ra malloc
        mv s9 a0 # s9 is the pointer for the memeory of col
        
        # check malloc error 
        beq s9 x0 malloc_error
        
        
    lw a0 12(s0)
    mv a1 s8
    mv a2 s9
    jal ra read_matrix
    mv s10 a0 # s10 store the m0 address
    

    # Compute h = matmul(m0, input)
    
        # malloc for the result
        lw t0 0(s2)
        lw t1 0(s9)
        mul t2 t0 t1
        slli t2 t2 2
        mv a0 t2
        jal ra malloc
        mv s11 a0 
        
        # check malloc error 
        beq s11 x0 malloc_error
        
    # matmul
    mv a0 s4
    lw a1 0(s2)
    lw a2 0(s3)
    
    mv a3 s10
    lw a4 0(s8)
    lw a5 0(s9)
    mv a6 s11
    
    jal ra matmul

    # Compute h = relu(h)
    mv a0 s11
    lw t0 0(s2)
    lw t1 0(s9)
    mul t2 t0 t1
    mv a1 t2
    
    jal ra relu

    # Compute o = matmul(m1, h)
    # malloc for the result
        lw t0 0(s5)
        lw t1 0(s9)
        mul t2 t0 t1
        slli t2 t2 2
        mv a0 t2
        jal ra malloc
        mv t6 a0 # s regs is not enough :(
        
        # check malloc error 
        beq t6 x0 malloc_error
        
    # matmul
    mv a0 s7
    lw a1 0(s5)
    lw a2 0(s6)
    
    mv a3 s11
    lw a4 0(s2)
    lw a5 0(s9)
    mv a6 t6
    
    addi sp sp -4
    sw t6 0(sp)
    
    jal ra matmul
    
    lw t6 0(sp)
    addi sp sp 4
    
    # Write output matrix o
    
    lw a0 16(s0)
    mv a1 t6
    lw a2 0(s5)
    lw a3 0(s9)
    
    addi sp sp -4
    sw t6 0(sp)
    
    jal ra write_matrix
    
    lw t6 0(sp)
    addi sp sp 4

    # Compute and return argmax(o)
    
    mv a0 t6
    lw t0 0(s5)
    lw t1 0(s9)
    mul t2 t0 t1
    mv a1 t2
    
    addi sp sp -4
    sw t6 0(sp)
    
    jal ra argmax
    mv t5 a0
    
    addi sp sp -4
    sw t5 0(sp)
    
    # If enabled, print argmax(o) and newline
 
    bne s1 x0 free_malloc
    
    mv a0 t5
    jal ra print_int
    
    li a0 '\n'
    jal ra print_char
    
free_malloc:
    
    lw t5 0(sp)
    lw t6 4(sp)
    addi sp sp 8

    addi sp sp -4
    sw t5 0(sp)
    
    mv a0 t6
    jal ra free
    mv a0 s2
    jal ra free
    mv a0 s3
    jal ra free
    mv a0 s4
    jal ra free
    mv a0 s5
    jal ra free
    mv a0 s6
    jal ra free
    mv a0 s7
    jal ra free
    mv a0 s8
    jal ra free
    mv a0 s9
    jal ra free
    mv a0 s10
    jal ra free
    mv a0 s11
    jal ra free
        
    lw t5 0(sp)
    addi sp sp 4
    
    mv a0 t5
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    lw s8 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52

    jr ra
    
arguments_error:
    li a0 31
    j exit
malloc_error:
    li a0 26
    j exit