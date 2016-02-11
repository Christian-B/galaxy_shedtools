import optparse  # using optparse as hydra still python 2.6
import os
import re
import sys


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
        return os.path.expanduser("~") + path[1:]
    return path


def do_walk(source, regex, onerror=None, followlinks=False, verbose=True):
    """
    Walker method
    Inputs are:
    source Parent directory to be walked through
    regex that files names must match
    onerror is a function on underlying os.listdir fails
    followlinks would allow following symbolic links
        WARNING Be aware that setting followlinks to True can lead to infinite
           recursion if a link points to a parent directory of itself.
           walk() does not keep track of the directories it visited already.
    verbose: Flag passed to action methods to provide more output
    """
    source = expanderuser(source)
    re_object = re.compile(regex)
    file_paths = []
    for root, dirs, files in os.walk(source, topdown=True, onerror=onerror, followlinks=followlinks):
        for name in files:
            if re_object.search(name):
                file_path = os.path.join(root, name)
                file_paths.append(file_path)
                if verbose:
                    print "Found", file_path
    if len(file_paths) == 0:
        report_error("NO files found to match " + regex)
    return file_paths


if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("--source", action="store", type="string",
                      default=os.getcwd(),
                      help="SOURCE directory of the sub directories to hold the data for each run "
                           "Default is the current directory")
    parser.add_option("--regex", action="store", type="string",
                      help="Regex pattern for identifying the left file")
    parser.add_option("--target_path", action="store", type="string",
                      help="Path to write file_names to")
    parser.add_option("--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    (options, args) = parser.parse_args()

    if not options.source:
        report_error("No source parameter provided")
    if not options.regex:
        report_error("No regex parameter provided")

    file_paths = do_walk(source=options.source, regex=options.regex, verbose=options.verbose)

    if options.target_path:
        with open(options.target_path, 'w') as f:
            for file_path in file_paths:
                f.write(file_path)
                f.write("\n")
    else:
        print file_paths
