.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:

    addi t0 x0 1 # t0 = 1
    blt a1 t0 exceptions
    add t0 x0 x0 # t0 = 0
    # Prologue
    addi sp sp -12
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)

loop_start:
    add s0 a0 x0 # s0 is the begin index of the array
    add s1 a1 x0 # s1 is the length of the array
    lw t6 0(a0) # t6 is the first number
    li a0 0
loop_continue:
    beq t0 s1 loop_end
    slli t1 t0 2 # t1 = t0 * 4
    add t2 s0 t1 # t2 is the 'th' index
    lw t3 0(t2) 
    blt t6 t3 record
    addi t0 t0 1
    j loop_continue
record:
    add t6 t3 x0 # t6 is the largest
    add a0 t0 x0 
    j loop_continue
loop_end:
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    addi sp sp 12
    
    jr ra
    
exceptions:
    li a0 36
    j exit
