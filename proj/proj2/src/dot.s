.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0 x0 1 # t0 = 1
    blt a2 t0 exception1
    blt a3 t0 exception2
    blt a4 t0 exception2
    # Prologue
    addi sp sp -20
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
loop_start:
    add s0 a0 x0 # s0 = a0
    add s1 a1 x0 # s1 = a1
    add t0 x0 x0 # t0 = 0
    addi t1 x0 4 # t1 = 4
    add t6 x0 x0 # t6 = 0
    mv s2 a3
    mv s3 a4 
  
loop_continue:
    beq t0 a2 loop_end
    mul t2 t1 s2 
    mul t3 t0 t2 
    add t3 s0 t3 # index of the first array
    lw t4 0(t3)
    
    mul t2 t1 s3
    mul t3 t0 t2
    add t3 s1 t3
    lw t5 0(t3)
    
    mul t5 t4 t5
    add t6 t6 t5 
    addi t0 t0 1
    j loop_continue
loop_end:
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 20
    mv a0 t6
    jr ra

exception1:
    li a0 36
    j exit

exception2:
    li a0 37
    j exit
