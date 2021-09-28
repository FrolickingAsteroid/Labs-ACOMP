# Computer Architectures
# Lab: Pipelining
# Nuno.Roma@ist.utl.pt
# IST, Lisbon-Portugal, 2020-05-04

# The following program processes two arbitrarily sized one-dimensional
# vectors composed by N integer elements, in order to execute
# the following pseudo-code algorithm:
 
#    int a[N] = { ..... }
#    int b[N] = { ..... }
#    int x = 1;
#    int n = 0;
#    register int i = 0;
#    while (b[i]>0){
#        x *= a[i] + a[N-1-i];
#        n += (N-1-i) - i;
#        i ++;
#    }

# Data section
        .data
# IMPORTANT: do not change this section
a:		.word  1, 5, 6, 6, 7, 2, 5, 2, 3, 2, 3, 4
b:		.word  4, 3, 1, 7, 2, 4, 9, -3, 5, 8, 1, 9
x: 		.word  1
n:		.word  0   

# Program section
		.text
		                            # NOTE: Upon start, the Global-Pointer (gp=x3) points to the beginning of .data section
		addi    x11, x3, 0			# x11 - a's left index

		lw 		x14, 100(x3)		# x14 - n - index distance accumulator
		lw		x15, 96(x3)			# x15 - x
		li 		x16, 0				# x16 - i

		addi    x13, x11, 48		# x13 - b's left index
		addi	a7, x0, 10
		addi	x12, x13, -4		# x12 - a's right index

while:	add		x20, x13, x16		# x20 = &b[i]
		lw		x21, 0(x20)			# x21 = b[i]
		lw 		x22, 0(x11)			# x22 = a[i]
		lw 		x23, 0(x12)			# x23 = a[N-1-i]
		blez	x21, end			# if b[i] <= 0 end the loop

		add		x22, x22, x23		# x22 = a[i] + a[N-1-i]
		mul 	x15, x15, x22		# x15 = x15*x22 (x *= a[i] + a[N-1-i])

		sub		x24, x12, x11		# x24 = 4*((N-1-i)-i)
		srai	x25, x24, 2			# x25 = x24/4
		add		x14, x14, x25		# n += x25

		lw		x21, 4(x20)			# x21 = b[i]
		lw 		x22, 4(x11)			# x22 = a[i]
		lw 		x23, -4(x12)			# x23 = a[N-1-i]
		blez	x21, end			# if b[i] <= 0 end the loop

		add		x22, x22, x23		# x22 = a[i] + a[N-1-i]
		mul 	x15, x15, x22		# x15 = x15*x22 (x *= a[i] + a[N-1-i])

		addi	x24, x24, -8
		srai	x24, x24, 2			# x24 = x24/4
		add		x14, x14, x24		# n += x24

		addi 	x16, x16, 8			# i++

		addi	x11, x11, 8
		addi	x12, x12, -8


		jal 	x0, while

end:	sw 		x14, 100(x3)		# store n's final value
		sw 		x15, 96(x3)			# store x's final value	

		ecall


# Expected result: M[x] = 1270080 = 136140h
#                  M[n] = 35      = 23h
