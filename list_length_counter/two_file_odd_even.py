import optparse  # using optparse as hydra still python 2.6

def split(input_path, odd_path, even_path, log_path):
    with open(input_path, 'r') as input_file:
        count = 0
        with open(odd_path, 'w') as odd_file:
            with open(even_path, 'w') as even_file:
                odd_line = True
                for line in input_file:
                    count+=1
                    if odd_line:
                        odd_file.write(line)
                        #odd_file.write("\n")
                        odd_line = False
                    else:
                        even_file.write(line)
                        #even_file.write("\n")
                        odd_line = True
        with open(log_path, 'a') as log_file:
            log_file.write(input_path)
            log_file.write(" ")
            log_file.write(str(count))
            log_file.write("\n")
    
if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option("--left_file", action="store", dest="left_file", type="string",
                      help="File to be read as left. ")
    parser.add_option("--right_file", action="store", dest="right_file", type="string",
                      help="File to be read as right. ")
    parser.add_option("--log_output", action="store", dest="log_output", type="string",
                      help="Path to log output file.")
    parser.add_option("--left_even_output", action="store", dest="left_even_output", type="string",
                      help="Path to left even output file.")
    parser.add_option("--left_odd_output", action="store", dest="left_odd_output", type="string",
                      help="Path to left odd output file.")
    parser.add_option("--right_odd_output", action="store", dest="right_odd_output", type="string",
                      help="Path to right odd output file.")
    parser.add_option("--right_even_output", action="store", dest="right_even_output", type="string",
                      help="Path to right even output file.")
    (options, args) = parser.parse_args()


split(options.left_file, options.left_odd_output, options.left_even_output, options.log_output)
split(options.right_file, options.right_odd_output, options.right_even_output, options.log_output)
