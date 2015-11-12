def quick_sort(list, size):

    print 'Sorting list of size', size
    
    list_left  = []
    count_left = 0
    list_right = []
    count_right = 0
    pivot = [list[0]]
    sorted_list = []
    for i in range(1,len(list)):
        if (int(list[i].BCID) > int(pivot[0].BCID)):
            list_right.append(list[i])
            count_right += 1
        elif (int(list[i].BCID) < int(pivot[0].BCID)):
            list_left.append(list[i])
            count_left += 1
        else:
            pivot = pivot + [list[i]]

    if count_left > 0:
        sorted_list = quick_sort(list_left, count_left) + pivot
    else:
        sorted_list = pivot

    if count_right > 0:
        sorted_list = sorted_list + quick_sort(list_right, count_right)

    return sorted_list

def __main__ ():
    unsorted_list = [2,3,69,1,7,2,5,5,4,4,5,2,2,5,5,5,2,1,9,8,8,7,8,5,2,1,4,5,215,2,4,5,1]
    print 'unsortedlist:\n', unsorted_list, '\n'
    
    sorted_list = quick_sort(unsorted_list, len(unsorted_list))
    print 'sortedlist:\n', sorted_list, '\n'

if __name__ == '__main__':
    __main__()
