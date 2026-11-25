# Student Name: [Your Full Name]
# Student ID:   26560019
# Purpose:      Lab 04 (TN3) - Listing 5: report(addr, n, mark) with sum_array, count_pass, spread, max_array, min_array, and show

.data
classA: .word 72, 55, 90, 48, 63, 85, 39, 77, 60, 94
classB: .word 45, 81, 66, 50, 92, 38, 70, 59
hdrA:   .asciiz "== Class A ==\n"
hdrB:   .asciiz "== Class B ==\n"
mTot:   .asciiz "Total:   "
mPass:  .asciiz "Passed:  "
mSpr:   .asciiz "Spread:  "
nl:     .asciiz "\n"

.text
.globl main
main:
    li   $v0, 4
    la   $a0, hdrA
    syscall
    la   $a0, classA            # report(classA, 10, M)
    addi $a1, $zero, 10
    addi $a2, $zero, 91         # pass mark M = 55 + 4 * D = 55 + 4 * 9 = 91
    jal  report

    li   $v0, 4
    la   $a0, hdrB
    syscall
    la   $a0, classB            # report(classB, 8, M)
    addi $a1, $zero, 8
    addi $a2, $zero, 91         # pass mark M = 55 + 4 * D = 55 + 4 * 9 = 91
    jal  report

    li   $v0, 10
    syscall

# report(addr = $a0, n = $a1, mark = $a2): prints total, passes and spread
report:
    addi $sp, $sp, -16          # frame: $ra, $s0, $s1, $s2
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)
    add  $s0, $a0, $zero        # $s0 = addr
    add  $s1, $a1, $zero        # $s1 = n
    add  $s2, $a2, $zero        # $s2 = mark
    jal  sum_array              # $v0 = total ($a0 and $a1 still hold addr, n)
    la   $a0, mTot
    add  $a1, $v0, $zero
    jal  show
    # call count_pass(addr, n, mark), taking the arguments from $s0, $s1, $s2
    add  $a0, $s0, $zero
    add  $a1, $s1, $zero
    add  $a2, $s2, $zero
    jal  count_pass
    # print its result with show and the message mPass
    la   $a0, mPass
    add  $a1, $v0, $zero
    jal  show
    # call spread(addr, n), then print its result with show and mSpr
    add  $a0, $s0, $zero
    add  $a1, $s1, $zero
    jal  spread
    la   $a0, mSpr
    add  $a1, $v0, $zero
    jal  show
    # restore $s2, $s1, $s0 and $ra, then give the frame back
    lw   $s2, 0($sp)
    lw   $s1, 4($sp)
    lw   $s0, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra

# spread(addr = $a0, n = $a1): returns largest - smallest in $v0
spread:
    addi $sp, $sp, -16          # frame: four words
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)            # save $s0 at 8($sp)
    sw   $a0, 4($sp)            # keep addr
    sw   $a1, 0($sp)            # keep n
    jal  max_array
    add  $s0, $v0, $zero        # keep the largest in $s0
    lw   $a0, 4($sp)
    lw   $a1, 0($sp)
    jal  min_array
    sub  $v0, $s0, $v0
    lw   $s0, 8($sp)            # restore $s0 from 8($sp)
    lw   $ra, 12($sp)           # restore $ra from 12($sp)
    addi $sp, $sp, 16           # give the frame back: add 16 to $sp
    jr   $ra

# max_array(addr = $a0, n = $a1): returns the largest of n words in $v0
max_array:
    lw   $v0, 0($a0)            # largest = element 0
    addi $t0, $zero, 1          # i = 1
max_loop:
    slt  $t1, $t0, $a1          # $t1 = 1 if i < n
    beq  $t1, $zero, max_end
    sll  $t2, $t0, 2
    add  $t2, $t2, $a0          # $t2 = address of element i
    lw   $t3, 0($t2)
    slt  $t1, $v0, $t3          # $t1 = 1 if largest < element i
    beq  $t1, $zero, max_next
    add  $v0, $t3, $zero        # new largest
max_next:
    addi $t0, $t0, 1            # i = i + 1
    j    max_loop
max_end:
    jr   $ra

# min_array(addr = $a0, n = $a1): returns the smallest of n words in $v0
min_array:
    lw   $v0, 0($a0)            # smallest = element 0
    addi $t0, $zero, 1          # i = 1
min_loop:
    slt  $t1, $t0, $a1          # $t1 = 1 if i < n
    beq  $t1, $zero, min_end
    sll  $t2, $t0, 2
    add  $t2, $t2, $a0          # $t2 = address of element i
    lw   $t3, 0($t2)
    slt  $t1, $t3, $v0          # $t1 = 1 if element i < smallest
    beq  $t1, $zero, min_next
    add  $v0, $t3, $zero        # new smallest
min_next:
    addi $t0, $t0, 1            # i = i + 1
    j    min_loop
min_end:
    jr   $ra

# sum_array(addr = $a0, n = $a1): returns the sum of n words in $v0
sum_array:
    addi $v0, $zero, 0          # sum = 0
    addi $t0, $zero, 0          # i = 0
sum_loop:
    slt  $t1, $t0, $a1          # $t1 = 1 if i < n
    beq  $t1, $zero, sum_end
    sll  $t2, $t0, 2            # $t2 = 4 * i
    add  $t2, $t2, $a0          # $t2 = address of element i
    lw   $t3, 0($t2)
    add  $v0, $v0, $t3          # sum = sum + element i
    addi $t0, $t0, 1            # i = i + 1
    j    sum_loop
sum_end:
    jr   $ra

# count_pass(addr = $a0, n = $a1, mark = $a2): count of words >= mark
count_pass:
    addi $v0, $zero, 0          # count = 0
    addi $t0, $zero, 0          # i = 0
cp_loop:
    slt  $t1, $t0, $a1          # $t1 = 1 if i < n, else 0
    beq  $t1, $zero, cp_end
    sll  $t2, $t0, 2            # $t2 = 4 * i
    add  $t2, $t2, $a0          # $t2 = address of element i
    lw   $t3, 0($t2)            # $t3 = element i
    slt  $t1, $t3, $a2          # $t1 = 1 if element i < mark
    bne  $t1, $zero, cp_next    # if element i < mark, skip increment
    addi $v0, $v0, 1            # count = count + 1
cp_next:
    addi $t0, $t0, 1            # i = i + 1
    j    cp_loop
cp_end:
    jr   $ra

# show(msg = $a0, value = $a1): prints msg, value and a new line
show:
    li   $v0, 4                 # $a0 already holds the address of msg
    syscall
    li   $v0, 1
    add  $a0, $a1, $zero
    syscall
    li   $v0, 4
    la   $a0, nl
    syscall
    jr   $ra