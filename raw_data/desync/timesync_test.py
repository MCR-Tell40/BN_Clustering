import sys
cutoff = 512
key = []

print 'len(sys.argv) =', len(sys.argv)

#--------------------------------------#

desync_count = []

for X in range(0,624):
    if len(sys.argv) == 1:
        file_name = 'desync' + str(X) + '.txt'
    else:
        file_name = 'desync' + sys.argv[1] + '.txt'
    with open(file_name) as in_file:
        raw_list = in_file.read()
        spp_list = raw_list.split('\n')
        key.append(raw_list[X][:9])
        line = 0
        distance = 0
        desync_counter = 0

        for each_spp in spp_list:
            if each_spp[:9] == key[X]:
                if distance > cutoff:
                    print 'instance in desync file', X, 'at line:' , line , '|', distance, 'since last instance'
                    desync_counter += 1
                distance = 0
            line += 1
            distance += 1
    
    desync_count.append(desync_counter)

#-------------------------------------#

timesync_count = []

for X in range(0,624):

    if len(sys.argv) == 1:
        file_name = 'timesync' + str(X) + '.txt'
    else:
        file_name = 'timesync' + sys.argv[1] + '.txt'
    with open(file_name) as in_file:
        raw_list = in_file.read()
        spp_list = raw_list.split('\n')

        line = 0
        distance = 0
        timesync_counter = 0

        for each_spp in spp_list:
            if each_spp[:9] == key[X]:
                if distance > 1:
                    print 'instance in timesync file', X, 'at line:' , line , '|', distance, 'since last instance'
                    timesync_counter += 1
                distance = 0
            line += 1
            distance += 1
    
    timesync_count.append(timesync_counter)

#----------------------------------------#

with open('loopdata.txt','w') as out_file:
    for X in range(0,624):
        if desync_count[X] > 0 or timesync_count[X] > 0:
            out_file.write(str(X) + '\t' + str(desync_count[X]) + '\t' + str(timesync_count[X]) + '\n')
