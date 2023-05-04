.globl abs
abs:
ebreak
  # Load number from memory
  lw t0 0(a0)
  bge t0, zero, done

  # Negate a0
  sub t0, x0, t0

  # Store number back to memory
  sw t0 0(a0)

done:
  ret