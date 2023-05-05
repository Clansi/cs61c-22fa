.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    
    # store
    mv s0 a0 
    mv s1 a1
    mv s2 a2
    mv s3 a3
    
    # open
    li a1 1
    jal ra fopen
    mv s4 a0 # store the fopen return value a0
    
    # check open error
    li t0 -1
    beq a0 t0 fopen_error

    # malloc for the memory of storing row
    li a0 4
    jal ra malloc
    mv t0 a0    # t0 is the address of storing row 
    sw s2 0(t0)
    
    # write row
    mv a0 s4
    mv a1 t0
    li a2 1
    li a3 4
    jal ra fwrite
    
    # check write error
    li t1 1
    bne a0 t1 fwrite_error
    
    # malloc for the memory of storing col
    li a0 4
    jal ra malloc
    mv t0 a0 
    sw s3 0(t0)
    
    # write col
    mv a0 s4
    mv a1 t0
    li a2 1
    li a3 4
    jal ra fwrite
    
    # check write error
    li t1 1
    bne a0 t1 fwrite_error
    
    # write the rest
    mv a0 s4
    mv a1 s1
    mul a2 s2 s3
    li a3 4
    jal ra fwrite
    
    # check write error
    mul t1 s2 s3
    bne a0 t1 fwrite_error
    
    # close
    mv a0 s4
    jal ra fclose
    
    # check close error
    bne a0 x0 fclose_error
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    addi sp sp 24
    
    jr ra
    
fopen_error:
    li a0 27
    j exit
fclose_error:
    li a0 28
    j exit
fwrite_error:
    li a0 30
    j exit
