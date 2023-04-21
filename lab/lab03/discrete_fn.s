.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (defined above).
# The return value should be stored in a0
f:
    addi t0 a0 3 # get the index of the output arr
    slli t1 t0 2 # t1 = t0 * 4 get the real index of the arr memory
    add t2 t1 a1
    lw a0 0(t2)
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra  