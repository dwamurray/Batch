'''
Supply a range of numbers from first to last and the integer
with which to divide by.  If the returned value is 0 then
it means the number in the range was divisible by the
integer without returning any fraction
'''

def divisible(first, last, divisor):
    count = 0
    for num in range(first, last+1):
        if num % divisor == 0:
            print num

'''
Example:
divisible(20,1000,17)
Will return all the numbers between 20 and 1000 inclusive
that can be divided by 17 and return a integer (whole)
value, 34, 51, 67 etc
'''
