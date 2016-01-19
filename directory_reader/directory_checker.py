import optparse  # using optparse as hydra still python 2.6
import os.path
import sys

def report_error(*args):
    sys.stderr.write(' '.join(map(str,args)) + '\n')
    sys.stderr.flush()
    sys.exit(1)

def get_tool_data(name):
    root_dir = os.path.dirname((os.path.realpath(__file__)))
    path = os.path.join(root_dir,"tool-data",name)
    if not(os.path.isfile(path)): 
        report_error(name,"file not found in tool's tool-data folder. Please ask you galaxy admin to add it back")
    return path

def check_white_list(path_to_check):
    white_list = get_tool_data("white-list.ini")
    with open(white_list, 'r') as white_list_file:
        for line in white_list_file:
            line = line.strip()
            if len(line) >= 1 and path_to_check.startswith(line):
                return True
    report_error(path_to_check,"has not been included in the white list. Please contact the local galaxy admin to add it.")

def check_black_list(path_to_check):
    black_list = get_tool_data("black-list.ini")
    with open(black_list, 'r') as black_list_file:
        for line in black_list_file:
            line = line.strip()
            if len(line) >= 1 and line in path_to_check:
                report_error(line,"has been black list so",path_to_check,"is not allowed. Please contact the local galaxy admin to change that, or add a symlink.")
    return True

if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option("--path_to_check", action="store", type="string",
                      help="Path of directory to check. ")
    (options, args) = parser.parse_args()


path = options.path_to_check.strip()
if path[-1] != '/':
    path = path + "/"
check_white_list(path)
print path, "white listed"
check_black_list(path)
print path, "not black listed"

