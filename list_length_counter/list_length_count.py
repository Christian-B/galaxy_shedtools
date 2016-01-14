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
    parser.add_option("-f", "--file", action="append", dest="files", type="string",
                      help="File to be read. ")
    parser.add_option("-l", "--list", action="store", dest="list", type="string",
                      help="Path to list of files names. If not provided files will be numbered.")
    parser.add_option("-s", "--start_number", action="store", dest="start_number", type="int", default=1,
                      help="Number to start count with if no list provided.")
    parser.add_option("-o", "--output", action="store", dest="output", type="string",
                      help="Path to output file.")
    (options, args) = parser.parse_args()

    names = file_names(options.list, options.files, options.start_number)
    print names

    with open(options.output, 'w') as output_file:
        file_number = -1
        for file_path in options.files:
            lines = 0
            chars = 0
            file_number+= 1
            with open(file_path, 'r') as in_file:
                for line in in_file:
                    lines+=1
                    chars+= len(line)
            output_file.write(names[file_number])
            output_file.write("   lines: ")
            output_file.write(str(lines))
            output_file.write("  chars: ")
            output_file.write(str(chars))
            output_file.write("\n")

