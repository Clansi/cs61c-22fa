.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    
    mv s0 a0 # store the initial a0
    mv s1 a1 # store the initial a1
    mv s2 a2 # store the initial a2
    
    # open
    li a1 0
    jal ra fopen
    mv s3 a0 # store the fopen return value a0
    
    # check open error
    li t0 -1
    beq a0 t0 fopen_error
    
    
    
    # read the number of rows
    mv a0 s3
    mv a1 s1
    li a2 4
    jal ra fread
    
    # check read error
    li t0 4
    bne a0 t0 fread_error
    
    # read the number of cols
    mv a0 s3
    mv a1 s2
    li a2 4
    jal ra fread
    
    # check read error
    li t0 4
    bne a0 t0 fread_error
    
    # malloc
    lw t0 0(s1)
    lw t1 0(s2)
    mul t2 t0 t1 # t2 is the number of atoms
    slli t2 t2 2
    mv a0 t2
    mv s4 t2
    jal ra malloc
    mv s5 a0 # store the result
    # check malloc error 
    beq a0 x0 malloc_error
    
    # read the rest
    mv a1 a0
    mv a0 s3
    mv a2 s4
    jal ra fread

    # check read error
    bne a0 s4 fread_error
    
    # close
    mv a0 s3
    jal ra fclose
    
    # check close error
    bne a0 x0 fclose_error
    
    # get the return
    mv a0 s5
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28
    
    jr ra

malloc_error:
    li a0 26
    j exit
fopen_error:
    li a0 27
    j exit
fclose_error:
    li a0 28
    j exit
fread_error:
    li a0 29
    j exit
