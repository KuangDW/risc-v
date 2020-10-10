# Assignment1: RISC-V Assembly and Instruction Pipeline
contributed by < `Kuang Da` >

==Requirement==
- [x] Don’t implement the same subject as others do. Your program shall be different.
- [x] Your program(s) MUST contain loops (or recursive calls) and conditional branches.
- [x] You have to ensure the program fully functioned with Ripes simulator.
- [ ] Explain your program with the visualization for multiplexer input selection, register write/enable signals and more.
- [ ] Illustrate each stage such as IF, ID, IE, MEM, and WB.
- [ ] Discuss the steps of memory updates accordingly.

## Collatz conjecture
:::info
The Collatz conjecture is a conjecture in mathematics that concerns a sequence defined as follows: start with any positive integer n. Then each term is obtained from the previous term as follows: if the previous term is even, the next term is one half of the previous term. If the previous term is odd, the next term is 3 times the previous term plus 1. The conjecture is that no matter what value of n, the sequence will always reach 1.
:::
![](https://i.imgur.com/qv4VFdc.png)
## Collatz conjecture Example
:::info
For instance, starting with n = 12, one gets the sequence 12, 6, 3, 10, 5, 16, 8, 4, 2, 1.

n = 19, for example, takes longer to reach 1: 19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1.

The sequence for n = 27, listed and graphed below, takes 111 steps (41 steps through odd numbers, in large font), climbing to a high of 9232 before descending to 1.

27, 82, 41, 124, 62, 31, 94, 47, 142, 71, 214, 107, 322, 161, 484, 242, 121, 364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1
:::
![](https://i.imgur.com/ecYeRMx.png)

### C code
```c=
#include<stdio.h> 

int count=0;
int f(int n) 
{
    if(n==1)
    {
        return count;
    }
    else if(n%2==0) 
    { 
        f(n/2);
        count++; 	
    }
    else 
    { 
        f(3*n+1);
        count++; 	 
    }
} 
int main(void) 
{ 
    int n=10; 
    int step=f(n); 
    printf("Collatz conjecture (%d) = %d",n,step);
}
```


### Assembly code
![](https://i.imgur.com/i0cY26X.png)

:::info
organized the variable assignment
:::
| variable        | register |  note |
|-----------------|----------|-------|
| count           | x3  = s1 |       |
| f's argument    | x5  = a0 |       |
| 1               | x28 = s0 |       |
| 2               | x12 = a2 |       |
| 3               | x6  = a3 |       |
| j condition     | x19 = t2 |       |
| step            | x18 = t1 |       |
| n               | x28 = t0 |       |


| info |     |
|------|-----|
|cycles|182  |
|Instrs|120  |
|CPI   |1.52 |
|IPC   |0.659|
|rate  |16.67|

## RISC-V assembly program (R32I ISA)
This code is my assembly program,having five different parts.
1. main
Initial values, store some data to memory and jump to the f
2. f
if(n != 1) jump to ELSEIF
or return count
4. ELSEIF
if(n%2 != 0) jump to ELSE
or call f(n/2) and count++
4. ELSE
call f(3*n+1) and count++
5. printResult
[Environment calls](https://github.com/mortbopet/Ripes/wiki/Environment-calls) are defined by Ripes simulator. If we want to print something, need to follow its rules. Using a0,a1 registers to activate system calls.
```cpp=
.data
count: .word    0
str1:  .string "Collatz conjecture ("
str2:  .string ") = "

.text
main:                          # initial value
        li    a0, 10
        li    s0, 1
        lw    s1, count        # count = 0
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

printResult:                   
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
        ecall                  # print int step
        ret

exit:
        li   a7, 10
        ecall                  # exit
```

### code result
```cpp=
Kakutani theorem (10) = 6
Program exited with code: 0
```


## Ripes simulator
### How a instuction works in pipeline CPU
First I need to introduce how a instruction run in Ripes simulator.Choose a instrction from fetch,and we will see how it progress to the end.

#### Fetch
![](https://i.imgur.com/aWEsC7X.png)

In the begininng, PC is 0 means instruction addr is 0 so go to instruction memory to find instruction 0x00a00513.
![](https://i.imgur.com/a72TU1u.png)

When we see the memory, we can ensure that addr 0 has a data 0x00a00513, so it is correct instruction.
![](https://i.imgur.com/BtTQf1d.png)

#### Decode
![](https://i.imgur.com/H0paBkX.png)

After decoder decode the instruction,we will known it need to read x10 registers. Getting one register data and a imm value 0x0000000A (10) because it is a addi instrcution.
![](https://i.imgur.com/et20iqz.png)
![](https://i.imgur.com/r2l73qJ.png)

#### Execute
![](https://i.imgur.com/NMn6qpx.png)

x10 register has a initial value 0x00000000,so ALU will calculate 0x00000000 + 0x0000000A (10) = 0x0000000A (10). In the meantime, addi x8 x0 1 in the decode. 
![](https://i.imgur.com/Xk0r77m.png)
![](https://i.imgur.com/9iRsZDg.png)

#### Mem
![](https://i.imgur.com/bcz5nWB.png)
Addi instruction don't need to access memory or write data. It just need to pass by the mem stage.
![](https://i.imgur.com/7kcB98E.png)
![](https://i.imgur.com/sAnWNnh.png)

#### WB

In write back stage we can see addi will write  0x0000000A (10) to x10 register.x10 is 0x7ffffff0 when addi in the WB stage. In next cycle x10 will update to  0x0000000A (10) from below table we can observe this .
![](https://i.imgur.com/Tgn2yKo.png)
![](https://i.imgur.com/UKdxriU.png)
![](https://i.imgur.com/LPfRy9o.png)

![](https://i.imgur.com/vtAlBZZ.png)
![](https://i.imgur.com/XPO5skd.png)
![](https://i.imgur.com/GUikYPI.png)
