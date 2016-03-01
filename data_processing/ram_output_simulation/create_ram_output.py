import sys
from copy import deepcopy

__packet_size__ = 24
__line_size__ = __packet_size__*16

def __main__():

	for module_number in range(0,52):
		for side_selection in range(0,2):

			asic_data = []

			if side_selection == 1:
				for x in range(3,9):
					asic_data.append(extract_cycle(module_number*12 + x))
			else:
				for x in range(0,3):
					asic_data.append(extract_cycle(module_number*12 + x))
				for x in range(9,12):
					asic_data.append(extract_cycle(module_number*12 + x))

			sensor_data = []

			for x in range(0,512):
				sensor_data.append(deepcopy(''))
				for y in range(0,6):
					sensor_data[x] += asic_data[y][x]

			with open(savefile_location + '/Module_' +  str(module_number) + '_' + str(side_selection) + '_sort.txt','w') as out_file_sort:
				with open(savefile_location + '/Module_' +  str(module_number) + '_' + str(side_selection) + '_overflow.txt','w') as out_file_overflow:
					with open (savefile_location + '/Module_' +  str(module_number) + '_' + str(side_selection) + '_count.txt','w') as out_file_count:
						for x in range(0,512):

							if x != 0:
								print '\033[A\r\033[K\033[A' #ascii excape: resets terminal print line
							print 'BCID:', x+1, '/ 512'
							
							out_file_count.write( pad_left(format(len(sensor_data[x])/24,'b'),8) + '\n')

							complete = False

							if (len(sensor_data[x]) < 3*__line_size__): # Sort Event
								while(complete == False):
									if len(sensor_data[x]) > __line_size__:
										out_file_sort.write(sensor_data[x][:__line_size__])
										sensor_data[x] = sensor_data[x][__line_size__:]
									elif len(sensor_data[x]) <= __line_size__:
										out_file_sort.write(pad_right(sensor_data[x],__line_size__))
										complete = True
									out_file_sort.write('\n')

							else: # Bypass Event
								while(complete == False):
									if len(sensor_data[x]) > __line_size__:
										out_file_overflow.write(sensor_data[x][:__line_size__])
										sensor_data[x] = sensor_data[x][__line_size__:]
									elif len(sensor_data[x]) <= __line_size__:
										out_file_overflow.write(pad_right(sensor_data[x],__line_size__))
										complete = True
									out_file_overflow.write('\n')

def pad_right(string,length):
	while(len(string) < length):
		string += '0'
	return string

def pad_left(string,length):
	while(len(string) < length):
		string = '0' + string
	return string

def extract_cycle(asic_number):

	print 'ASIC: ' + str(asic_number)

	with open(timesync_location + '/timesync' + str(asic_number) + '.txt') as in_file:
		data = in_file.read().split('\n')

	last_bcid = -1
	store = 0

	output = []
	for x in range(0,512):
		output.append(deepcopy(''))

	for spp in data:

			bcid = gray_to_int(spp[:9])

			if (bcid - last_bcid) < 0:

				if store == 0:
					
					store = 1
				
				elif store == 1:
					 
					 return output

			last_bcid = bcid
				
			if store == 1:
				output_string = (format(asic_number%6,'b') + spp[9:])
				if len(output_string) == 21:
					output[bcid] += '000' + output_string
				elif len(output_string) == 22:
					output[bcid] += '00' + output_string
				elif len(output_string) == 23:
					output[bcid] += '0' + output_string
				elif len(output_string) == 24:
					output[bcid] += output_string
				else:
					print 'incorrect output'

def gray_to_int(gray_string):
	value = 0
	value_string = gray_string[0]

	for x in range(1,len(gray_string)):
		if value_string[x-1] == gray_string[x]:
			value_string += '0'
		else:
			value_string += '1'

	for char in value_string:
		value = value << 1
		value = value | int(char)


	return value

if __name__ == '__main__':

	timesync_location 	= sys.argv[1]
	savefile_location	= sys.argv[2]

	__main__()
