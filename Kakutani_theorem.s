
.data
count: .word    1
str1:     .string "Collatz conjecture ("
str2:     .string ") = "

.text
main:                          # initial value
	li    a0, 10
	li    s0, 1
 	lw    s1, count        # count = 1
        jal   ra, f            # call f(10)
        jal   ra, printResult  # print result
        j     exit             # go to exit

f:
        bne   a0, s0, ELSEIF   # if(n != 1) jump to ELSEIF
        ret                    # return
ELSEIF:
	li    a2, 2
        rem   t2, a0, a2       # n%2
        bne   t2, zero, ELSE   # if(n%2 != 0) jump to ELSE
	addi  sp, sp, -12      # push the stack
        sw    ra, 8(sp)        # store return address
        sw    a0, 4(sp)        # store argument n
        div   a0, a0, a2       # argument = n/2
        jal   ra, f            # call f(n/2)
	sw    a0, 0(sp)        # store return value of f(n/2)
        lw    a0, 4(sp)        # load argument n
	lw    ra, 8(sp)        # load return address
        addi  sp, sp, 12       # pop the stack
	addi  s1, s1, 1        # count++
        ret                    # return

ELSE:
	li    a3, 3
	addi  sp, sp, -12      # push the stack
        sw    ra, 8(sp)        # store return address
        sw    a0, 4(sp)        # store argument n
	mul   a0, a0, a3       # n*3
	addi  a0, a0, 1		   # n*3+1
        jal   ra, f            # call f(3*n+1)
	sw    a0, 0(sp)        # store return value of fib(n - 1)
        lw    a0, 4(sp)        # load argument n
	lw    ra, 8(sp)        # load return address
        addi  sp, sp, 12       # pop the stack
	addi  s1, s1, 1        # count++
        ret                    # return

printResult:                   # Fibonacci(10) = 55
        mv    t0, a0
        mv    t1, s1
        la    a0, str1
        li    a7, 4
        ecall                  # print string str1
        mv    a0, t0
        li    a7, 1
        ecall                  # print int argument n
        la    a0, str2
        li    a7, 4
        ecall                  # print string str2
        mv    a0, t1
        li    a7, 1
        ecall                  # print int result
        ret

exit:
        li   a7, 10
        ecall                  # exit
