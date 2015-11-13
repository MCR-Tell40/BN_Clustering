def stob(str_to_bin):
    count = len(str_to_bin) -1
    value = 0
    for char in str_to_bin:
         value += int(char) * (2 ** count)
         count -= 1
    return value

