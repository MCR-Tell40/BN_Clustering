
out_file = open('desyncX.txt','w')

for x in range(0,624):
    print x
    with open('desync' + str(x) + '.txt') as in_file:
        contents = in_file.read()
        contents = contents.split()
        
        for line in contents:
            if line != '':
                out_file.write(line + '\n')

        
