#                         ICS 51, Lab #4
#
#      IMPORTANT NOTES:
#
#      Write your assembly code only in the marked blocks.
#
#      DO NOT change anything outside the marked blocks.
#
###############################################################
#                           Text Section
.text

###############################################################
###############################################################
#                       PART 1 (Image Thresholding)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
#a3: threshold value 
###############################################################
threshold:
############################## Part 1: your code begins here ###
	addu $t0, $0, 0xFF #max pos value
	addu $t1, $0, 0x00 #min pos value
	mul $t2, $a2, $a2 #num of index
	

	threshold_loop:
		beqz $t2, end_threshold_loop
		lbu $t3, ($a0)
		bge $t3, $a3, set_max
		sb $t1, ($a1)   
		j thresh_end
		set_max:
		sb $t0, ($a1)
		thresh_end:
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		subi $t2, $t2, 1
 		j threshold_loop
	end_threshold_loop: 
############################## Part 1: your code ends here ###
jr $ra

###############################################################
###############################################################
#                           PART 2 (Matrix Transform)
#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e., number of pixels = a3*a3)
###############################################################
transform:
############################### Part 2: your code begins here ##
li $t0, 0 # col index (x)
li $t1, 0 # row index (y)
li $t2, 0 # y0
li $t3, 0 # x0
li $t5, 0 #off set for input
li $t6, 0 # off set for output


col_loop:
bge $t0, $a3, row_loop
lw $t4, 0($a2) #M_00
mul $t4, $t4, $t0 #M_00*x
add $t3, $t3, $t4 # x0 = M_00*x
lw $t4, 4($a2)# M_01
mul $t4, $t4, $t1 # M_01*y
add $t3, $t3, $t4 # x0 = M_00*x + M_01*y
lw $t4, 8($a2) # M_02
add $t3, $t3, $t4 # x0 = M_00*x + M_01*y +_ M_02

lw $t4, 12($a2) #M_10
mul $t4, $t4, $t0 #M_10*x
add $t2, $t2, $t4 # y0 = M_00*x
lw $t4, 16($a2)# M_01
mul $t4, $t4, $t1 # M_01*y
add $t2, $t2, $t4 # y0 = M_00*x + M_01*y
lw $t4, 20($a2) # M_02
add $t2, $t2, $t4 # y0 = M_00*x + M_01*y +_ M_02


##################input################
mul $t5, $t2, $a3 # row index * num_col
add $t5, $t5, $t3 # row index * num_col + col index
mul $t7, $t5, 1
add $t7, $t7, $a0 

##################output################
mul $t6, $t1, $a3 # row index * num_col
add $t6, $t6, $t0 # row index * num_col + col index
mul $t8, $t6, 1
add $t8, $t8, $a1 




blt $t2, $0, else
bge $t2, $a3, else
blt $t3, $0, else
bge $t3, $a3, else
lbu $t5, ($t7)
sb $t5, ($t8)
j col_end

else:
sb $0, ($t8)

col_end:
addi $t0, $t0, 1
li $t2, 0 # y0
li $t3, 0 # x0


li $t5, 0 #off set
li $t6, 0
li $t7, 0
li $t8, 0
j col_loop

row_loop:
li $t0, 0 # reset col
bge $t1, $a3, end_loop
addi $t1, $t1, 1
j col_loop

end_loop:

############################### Part 2: your code ends here  ##
jr $ra
###############################################################
