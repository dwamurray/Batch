'''
Supply a range of numbers from first to last and the integer
with which to divide by.  If the returned value is 0 then
it means the number in the range returns an integer when
divided by the divisor
'''

def divisible(first, last, divisor):
    for num in range(first, last+1):
        if num % divisor == 0:
            print(num)

divisible(20,1000,17)
  
'''
Will return all the numbers between 20 and 1000 inclusive
that can be divided by 17 and return a integer (whole)
value, 34, 51, 68 etc
'''
