for num in range(20, 1001):
    if num % 17 == 0:
        print num
		
		
		
		

def divisible(first, last, divisor):
    count = 0
    for num in range(first, last+1):
        if num % divisor == 0:
            print num
