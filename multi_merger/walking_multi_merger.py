import optparse  # using optparse as hydra still python 2.6
import os
import re
import sys
import tempfile

def report_error(error):
    """Prints the error, usage (if possible) and exits -1"""
    #print error
    #if parser:
        # parser.print_help()
    print error
    sys.exit(1)

def expanderuser(path):
    """Replaces the ~ with the users home directory"""
    if path.startswith("~"):
        return os.path.expanduser("~") + path[1: ]
    return path

def multiple_match(regex, old_name, name):
    report_error(regex+" matched both " + old_name + " and " + name + "strickter regex required")

def do_walk(source, regex, target_path, onerror=None, followlinks=False, verbose=True):
    """
    Walker method
    Inputs are:
    source Parent directory to be walked through
    onerror is a function on underlying os.listdir fails
    followlinks would allow following symbolic links
        WARNING Be aware that setting followlinks to True can lead to infinite
           recursion if a link points to a parent directory of itself.
           walk() does not keep track of the directories it visited already.
    verbose: Flag passed to action methods to provide more output
    """
    source = expanderuser(source)
    (names_number, names_path) = tempfile.mkstemp()
    re_object = re.compile(regex)
    file_paths = []
    with open(names_path, 'w') as f:
        # Must be topdown=True otherwise walk will process subdirectories before checking them
        for root, dirs, files in os.walk(source, topdown=True, onerror=onerror, followlinks=followlinks):
            for name in files:
                if re_object.search(name):
                    file_path = os.path.join(root, name)
                    f.write(file_path)
                    f.write("\n")
                    file_paths.append(file_path)
                    if verbose:
                        print "Merging",file_path
    merge_files(file_paths, names_path, target_path)


if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("-v", "--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    parser.add_option("-s", "--source", action="store", type="string",
                  default=os.getcwd(),
                  help="SOURCE directory of the sub directories to hold the data for each run "
                  "Default is the current directory")
    parser.add_option("-c", "--code", action="store", type="string",
                  help="Path to file that defines what to do with the files. "
                  "Must define the function merge_files(file_paths, names_path, target_path)")
    parser.add_option("-r", "--regex", action="store", type="string",
                  help="Regex pattern for identifying the left file")
    parser.add_option("-t", "--target_path", action="store", type="string",
                  help="Path to write merged data to")
    (options, args) = parser.parse_args()

    if not options.code:
        report_error("No CODE parameter provided")
    execfile(options.code)
    if not options.regex:
        report_error("No REGEX parameter provided")
    if not options.target_path:
        report_error("No TARGET_PATH parameter provided")

    do_walk(source=options.source, regex=options.regex, target_path=options.target_path, verbose=options.verbose)

