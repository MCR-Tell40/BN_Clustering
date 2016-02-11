import sys

def bin_int(bin):
	count = len(bin) - 1
    value = 0
    for char in str_to_bin:
         value += int(char) * (2 ** count)
         count -= 1
    return value

def extract_row(spp):
	return bin_int(spp[14:22])

def __main__():

	with open(sys.argv[1]) as in_file:

		datatrain = infile.read().split('n')

	is_sorted = 1
	last_row = 0

	for each in datatrain:
		print each, ' | row = ', extract_row(each), '\n'
		if (extract_row(each) < last_row):
			is_sorted = 0
		last_row = extract_row(each)

	if is_sorted == 1:
		print 'datatrain sorted'
	else
		print 'datatrain NOT sorted'

if __name__ == __main__:
	__main__()