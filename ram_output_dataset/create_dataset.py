import sys
from copy import deepcopy

def __main__():

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

	with open(savefile,'w') as out_file:
		for x in range(0,512):
			if x != 0:
				print '\033[A\r\033[K\033[A'
			print x
			complete = 0
			while(complete == 0):
				if len(sensor_data[x]) > 384:
					out_file.write(sensor_data[x][:384])
					sensor_data[x] = sensor_data[x][384:]
				elif len(sensor_data[x]) == 384:
					out_file.write(sensor_data[x])
					complete = 1
				else:
					out_file.write(pad(sensor_data[x]))
					complete = 1
				out_file.write('\n')

def pad(string):
	while(len(string) < 384):
		string += '0'
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
				output_string = (int_to_bin(asic_number%6) + spp[9:])
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

def int_to_bin(integer):
	output = ''
	remaining_int = integer

	while remaining_int > 0:

		if (remaining_int & 1 == 1):
			output += '1'
		else:
			output += '0'

		remaining_int = remaining_int >> 1

	output = output[::-1]

	return output



if __name__ == '__main__':

	timesync_location 	= sys.argv[1]
	savefile 			= sys.argv[2]
	module_number 		= int(sys.argv[3])
	side_selection 		= int(sys.argv[4])

	__main__()
