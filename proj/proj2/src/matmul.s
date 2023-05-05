.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
    li t0, 1
    # Check if the height or width of either matrix is less than 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    
    # Check if the number of columns (width) of the first matrix A is not equal to 
    # the number of rows (height) of the second matrix B
    bne a2, a4, error

	# Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    mv s0, a0  # 's0' is the pointer to the start of m0
    mv s1, a1  # 's1'(n) is the rows (height) of m0
    mv s2, a2  # 's2'(m) is the columns (width) of m0
    mv s3, a3  # 's3' is the pointer to the start of m1
    mv s4, a4  # 's4'(m) is the rows (height) of m1
    mv s5, a5  # 's5'(k) is the columns (width) of m1
    mv s6, a6  # 's6' is the pointer to the the start of d
    addi t0, x0, 0  # 't0'(i) is the index used to traverse the array
    
outer_loop_start:
    addi t1, x0, 0  # 't1'(j) is the index used to traverse the array
    
inner_loop_start:
    mul t2, s5, t0
    add t2, t2, t1  # k * i + j
    slli t2, t2, 2
    add t2, t2, s6  # the address of d[k * i + j]
    
    mul t3, s4, t0  # m * i
    slli t3, t3, 2
    add t3, t3, s0  # the address of m0[m * i]
    
    mv t4, t1
    slli t4, t4, 2
    add t4, t4, s3  # the address of m1[j]
    
    # Store t0, t1, t2, t3, t4
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    
    # Calling dot function
    mv a0, t3
    mv a1, t4
    mv a2, s4
    li a3, 1
    mv a4, s5
    jal ra, dot
    
    # Restore t0, t1, t2, t3, t4
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    addi sp, sp, 20
    
    sw a0, 0(t2)
    addi t1, t1, 1
    blt t1, s5, inner_loop_start

inner_loop_end:
    addi t0, t0, 1
    blt t0, s1, outer_loop_start

outer_loop_end:
	# Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    
	ret

error:
    li a0, 38
    j exit