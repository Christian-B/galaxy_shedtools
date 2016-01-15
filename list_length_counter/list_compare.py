import optparse  # using optparse as hydra still python 2.6

def appendInt(num):
    if num > 9:
        secondToLastDigit = str(num)[-2]
        if secondToLastDigit == '1':
            return str(num) + 'th'
    lastDigit = num % 10
    if (lastDigit == 1):
        return str(num) + 'st'
    elif (lastDigit == 2):
        return str(num) + 'nd'
    elif (lastDigit == 3):
        return str(num) + 'rd'
    else:
        return str(num) + 'th'

def file_names(list_path, files, start_number):
    names = list()
    if list_path:
        with open(list_path, 'r') as list_file:
            for line in list_file:
                names.append(line.strip())
        if len(names) != len(files):
            raise Exception("Length of list " + list_path + " is " + str(len(names)) + " while " + str(len(files)) + " files specified")
    else:
        for i in range(start_number,len(files)+start_number):
            names.append(appendInt(i))
    return names

if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option("-l", "--left_files", action="append", dest="left_files", type="string",
                      help="File to be read as left. ")
    parser.add_option("-r", "--right_files", action="append", dest="right_files", type="string",
                      help="File to be read as right. ")
    parser.add_option("-n", "--names", action="store", dest="names", type="string",
                      help="Path to list of files names. If not provided files will be numbered.")
    parser.add_option("-s", "--start_number", action="store", dest="start_number", type="int", default=1,
                      help="Number to start count with if no list provided.")
    parser.add_option("-o", "--output", action="store", dest="output", type="string",
                      help="Path to output file.")
    (options, args) = parser.parse_args()

    if len(options.left_files) == 0:
        raise Exception("No files listed")
    if len(options.left_files) != len(options.right_files):
        raise Exception("Length of left list: " + str(len(options.left_file)) + " != length of right list: " + str(len(options.right_files)) )
        
    names = file_names(options.names, options.left_files, options.start_number)
    print names

    with open(options.output, 'w') as output_file:
        for file_number in range(len(options.left_files)):
            left_lines = 0
            left_chars = 0
            with open(options.left_files[file_number], 'r') as in_file:
                for line in in_file:
                    left_lines+=1
                    left_chars+= len(line)
            right_lines = 0
            right_chars = 0
            with open(options.right_files[file_number], 'r') as in_file:
                for line in in_file:
                    right_lines+=1
                    right_chars+= len(line)      
            output_file.write(names[file_number])
            if left_lines == right_lines:
                output_file.write("   lines: ")
                output_file.write(str(left_lines))
                if left_chars == right_chars:
                    output_file.write("  chars: ")
                    output_file.write(str(left_chars))
                elif left_chars > right_chars:
                    output_file.write("  left chars: ")
                    output_file.write(str(left_chars))
                else: 
                    output_file.write("  right chars: ")
                    output_file.write(str(right_chars))
            elif left_lines > right_lines:
                output_file.write("   left lines: ")
                output_file.write(str(left_lines))
            else:
                output_file.write("   right lines: ")
                output_file.write(str(right_lines))
            output_file.write("\n")

