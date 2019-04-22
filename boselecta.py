print('''
=========================
Select from three options
=========================

1: The first option
2: The second option
3: The third option
''')

number_is_valid=False
while number_is_valid==False:
    try:                          
        number_text = input('Please enter the number of the option you want: ') 
        number = int(number_text)  
        number_is_valid=True
    except ValueError:
        print('Invalid number text. Please enter digits.')
    except KeyboardInterrupt: 
        print('\nPlease do not try to escape.  Make your selection.')

if number == 1:
    print('You have selected the first option')
    print('This is safe for all the family')
else:
    age_text = input('Please enter your age: ')
    age = int(age_text)
    if number == 2:
        print('You have selected the second option')
        if age >= 16:
            print('Welcome to the party')
        else:
            print('Sorry. You are too young for the second option.')
    if number == 3:
        print('You have selected the third option')
        if age >= 16:
            if age > 55:
                print('Sorry. You are too old for the third option.')
            else:
                print('Go wild and have a good time')
        else:
            print('Sorry. You are too young for the third option.')
