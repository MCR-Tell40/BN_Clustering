#binary string to int
def btoi(str_to_bin): 
    count = len(str_to_bin) -1
    value = 0
    for char in str_to_bin:
         value += int(char) * (2 ** count)
         count -= 1
    return value

#gray string to bin striny
def gtob(gray):

    binary = gray[0] #msb always same
    
    for bit in range(1,len(gray)):
        if gray[bit] == '1' and binary[bit-1] == '1':
            binary += '0'
        elif gray[bit] == '1' and binary[bit-1] == '0':
            binary += '1'
        else:
            binary += binary[bit-1]

    return binary

def gtoi(gray):
    return btoi(gtob(gray))
