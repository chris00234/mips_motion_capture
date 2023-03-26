.include "lab4.asm"

#                      ICS 51, Lab #4 Test 
#                    DO NOT submit this file
#
###############################################################
#                           Data Section
.data

identity_m: .word 1, 0, 0, 0, 1, 0
scale_m:    .word 2, 0, 0, 0, 1, 0
rotation_m: .word 0, 1, 0, 1, 0, 0
shear_m:    .word 1, 1, 0, 0, 1, 0

input_1: .byte 100, 60, 81, 2
input_2: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
input_3: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
output_1: .byte 1, 2, 3, 4
output_2: .byte 1, 2, 3, 4, 5, 6, 7, 8, 9
output_3: .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

# Part 1 tests data
# thresh value = 128
test_11_expected_output: .byte 0, 0, 0, 0
test_12_expected_output: .byte 0, 0, 0, 0, 0, 255, 255, 255, 255
test_13_expected_output: .byte 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0

# Part 2 tests data
# identity and rotation on input 2
test_221_expected_output: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
test_222_expected_output: .byte 10 30 0 110 130 0 210 230 0
test_223_expected_output: .byte 10, 110, 210, 20, 127, 220, 30, 130, 230
test_224_expected_output: .byte 10 20 30 127 130 0 230 0 0
# identity, scale, rotation, and shear on input 3
test_231_expected_output: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
test_232_expected_output: .byte 0, 20, 0, 0, 40, 128, 0, 0, 140, 220, 0, 0, 240, 255, 0, 0
test_233_expected_output: .byte 0, 40, 140, 240, 10, 110, 210, 250, 20, 128, 220, 255, 30, 130, 230, 55
test_234_expected_output: .byte 0, 10, 20, 30, 110, 128, 130, 0, 220, 230, 0, 0, 55, 0, 0, 0
# Messages
new_line: .asciiz "\n"
space: .asciiz " "
i_str: .asciiz  "Program input:   " 
po_str: .asciiz "Program output:  " 
eo_str: .asciiz "Expected output: " 
t1_str: .asciiz "Testing part 1: \n" 
t2_str_0: .asciiz "Testing part 2 (identity): \n" 
t2_str_1: .asciiz "Testing part 2 (scale): \n" 
t2_str_2: .asciiz "Testing part 2 (rotation): \n" 
t2_str_3: .asciiz "Testing part 2 (shear): \n" 

# Files
fin: .asciiz "lena.pgm"
fout_thresh: .asciiz "lena_thresh.pgm"
fout_rotate: .asciiz "lena_rotation.pgm"
fout_shear: .asciiz "lena_shear.pgm"
fout_scale: .asciiz "lena_scale.pgm"

# Input/output buffers
.align 2
in_buffer: .space 400000
in_buffer_end:
.align 2
out_buffer: .space 400000
out_buffer_end:

###############################################################
#                           Text Section
.text

# Utility function to print byte arrays
#a0: array
#a1: length
print_array:
    li $t1, 0
    move $t2, $a0
    print:
    lb $a0, ($t2)
    andi $a0, $a0, 0xff
    li $v0, 1   
    syscall
    li $v0, 4
    la $a0, space
    syscall
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    blt $t1, $a1, print
    jr $ra

########################################################################################
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array
# Test transform function
########################################################################################
test_transform_function_wrapper:
    # Create space
    addi $sp, $sp, -28

    # save ra
    sw $ra, 24($sp)
    # save args
    sw $a0, 20($sp)
    sw $a1, 16($sp)
    sw $a2, 12($sp)
    sw $a3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    #a0: input buffer address
    #a1: output buffer address
    #a2: transform matrix address
    #a3: image dimension  (Image will be square sized, i.e. total size = a3*a3)
    jal transform 

    # restore args
    lw $s5, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)

    # s5: exp arraay
    # s4: input string
    # s3: input dimenstion
    # s2: matrix
    # s1: user out
    # s0: inputd

    mul $s3, $s3, $s3

	li $v0, 4
    move $a0, $s4
    syscall
    la $a0, i_str
    syscall
    move $a0, $s0
    move $a1, $s3
    jal print_array
    li $v0, 4
    la $a0, new_line
    syscall

    la $a0, po_str
    syscall
    move $a0, $s1
    move $a1, $s3
    jal print_array
    li $v0, 4
    la $a0, new_line
    syscall
    la $a0, eo_str
    syscall
    move $a0, $s5
    move $a1, $s3
    jal print_array
    li $v0, 4
    la $a0, new_line
    syscall
    syscall

    # restore ra
    lw $ra, 24($sp)
    addi $sp, $sp, 28

    jr $ra


# ******************************************************************
#open the file for reading
open_test_file: 
    li   $v0, 13       # system call for open file
    la   $a0, fin      # board file name
    li   $a1, 0        # Open for reading
    li   $a2, 0
    syscall            # open a file (file descriptor returned in $v0)
    move $s6, $v0      # save the file descriptor

    #read from file
    li   $v0, 14       # system call for read from file
    move $a0, $s6      # file descriptor
    la   $a1, in_buffer   # address of buffer to which to read
    la   $a2, in_buffer_end     # hardcoded buffer length
    sub $a2, $a2, $a1
    syscall            # read from file

    # Close the file
    li   $v0, 16       # system call for close file
    move $a0, $s6      # file descriptor to close
    syscall

    ## Copy the header
    la $t0, in_buffer
    la $t1, out_buffer
    lw $t2, ($t0)
    sw $t2, ($t1)
    lw $t2, 4($t0)
    sw $t2, 4($t1)
    lw $t2, 8($t0)
    sw $t2, 8($t1)
    lw $t2, 12($t0)
    sw $t2, 12($t1)

    jr $ra
# ******************************************************************

# ******************************************************************
# Open a file for writing
close_test_file:
    li   $v0, 13          # system call for open file
    li   $a1, 1        # Open for writing
    li   $a2, 0
    syscall            # open a file (file descriptor returned in $v0)
    move $s6, $v0      # save the file descriptor
    # write back
    li   $v0, 15       # system call for read from file
    move $a0, $s6      # file descriptor
    la   $a1, out_buffer   # address of buffer to which to read
    la   $a2, out_buffer_end     # hardcoded buffer length
    subu $a2, $a2, $a1
    syscall            # read from file

    # Close the file
    li   $v0, 16       # system call for close file
    move $a0, $s6      # file descriptor to close
    syscall  

    jr $ra
# ******************************************************************

###############################################################
#                          Main Function
.globl main
main:

# ***************** Part 1 testing starts ************
# Test threshold function
li $v0, 4
la $a0, t1_str
syscall

la $a0, input_1
la $a1, output_1
li $a2, 2
li $a3, 128
jal threshold

li $v0, 4
la $a0, i_str
syscall
la $a0, input_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_11_expected_output
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_2
la $a1, output_2
li $a2, 3
li $a3, 128
jal threshold

li $v0, 4
la $a0, i_str
syscall
la $a0, input_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_12_expected_output
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_3
la $a1, output_3
li $a2, 4
li $a3, 128
jal threshold

li $v0, 4
la $a0, i_str
syscall
la $a0, input_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_13_expected_output
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall
# ***************** Part 1 testing ends ************

# ***************** Part 2 testing starts ************
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array

# ***************** Part 2 Test Case 1 starts ************
la $a0, input_2
la $a1, output_2
la $a2, identity_m
li $a3, 3 # dim
la $s4, t2_str_0
la $s5, test_221_expected_output
jal test_transform_function_wrapper

la $a0, input_2
la $a1, output_2
la $a2, scale_m
li $a3, 3 # dim
la $s4, t2_str_1
la $s5, test_222_expected_output
jal test_transform_function_wrapper

la $a0, input_2
la $a1, output_2
la $a2, rotation_m
li $a3, 3 # dim
la $s4, t2_str_2
la $s5, test_223_expected_output
jal test_transform_function_wrapper

la $a0, input_2
la $a1, output_2
la $a2, shear_m
li $a3, 3 # dim
la $s4, t2_str_3
la $s5, test_224_expected_output
jal test_transform_function_wrapper
# ***************** Part 2 Test Case 1 ends ************

# ***************** Part 2 Test Case 2 starts ************
la $a0, input_3
la $a1, output_3
la $a2, identity_m
li $a3, 4 # dim
la $s4, t2_str_0
la $s5, test_231_expected_output
jal test_transform_function_wrapper

la $a0, input_3
la $a1, output_3
la $a2, scale_m
li $a3, 4 # dim
la $s4, t2_str_1
la $s5, test_232_expected_output
jal test_transform_function_wrapper

la $a0, input_3
la $a1, output_3
la $a2, rotation_m
li $a3, 4 # dim
la $s4, t2_str_2
la $s5, test_233_expected_output
jal test_transform_function_wrapper

la $a0, input_3
la $a1, output_3
la $a2, shear_m
li $a3, 4 # dim
la $s4, t2_str_3
la $s5, test_234_expected_output
jal test_transform_function_wrapper
# ***************** Part 2 Test Case 2 ends ************
# ***************** Part 2 testing ends ************

# ********************************************************
# *************** Test on real images start **************

# ********************************************************
# ***************** Threshold test start *****************
jal open_test_file

# Threshold
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
li $a2, 512
li $a3, 80
jal threshold 

la $a0, fout_thresh
jal close_test_file
# ***************** Threshold test end *****************

# ********************************************************
# ***************** Rotation test start *****************
jal open_test_file

# Rotate
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, rotation_m
li $a3, 512
jal transform 

la $a0, fout_rotate
jal close_test_file
# ***************** Rotation test end *****************


# ********************************************************
# ******************* Shear test start *******************
jal open_test_file

# Shear
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, shear_m
li $a3, 512
jal transform 

la $a0, fout_shear
jal close_test_file
# ******************* Shear test end *******************

# ********************************************************
# ******************* Scale test start *******************
jal open_test_file

# scale
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, scale_m
li $a3, 512
jal transform 
    
la $a0, fout_scale
jal close_test_file
# ********************** Scale test end *********************

# ***************** Test on real images end *****************

_end_program:
# end program
li $v0, 10
syscall
