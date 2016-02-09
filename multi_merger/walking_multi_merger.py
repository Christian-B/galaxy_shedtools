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

def do_walk(source, regex, target_path, onerror=None, followlinks=False, verbose=True, divider=None, sort=None, na_value=None):
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
                #else:
                #    print "NO",name, root
    if len(file_paths) == 0:
        report_error("NO files found to match "+ regex)

    kwargs = {"verbose": verbose}
    if divider:
        kwargs["divider"] = divider
    if sort:
        kwargs["sort"] = sort
    if na_value:
        kwargs["na_value"] = na_value
    merge_files(file_paths, names_path, target_path, **kwargs)


if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    parser.add_option("--source", action="store", type="string",
                  default=os.getcwd(),
                  help="SOURCE directory of the sub directories to hold the data for each run "
                  "Default is the current directory")
    parser.add_option("--code", action="store", type="string",
                  help="Path to file that defines what to do with the files. "
                  "Must define the function merge_files(file_paths, names_path, target_path, verbose)  May include and optional divider field.")
    parser.add_option("--regex", action="store", type="string",
                  help="Regex pattern for identifying the left file")
    parser.add_option("--target_path", action="store", type="string",
                  help="Path to write merged data to")
    parser.add_option("--divider", action="store", type="string",
                      help="Divider between key and value. Special symbols can be entered using galaxy code or __acsii__ . "
                           "Note: After splitiing on divider both parts will be trimmed for whitespace.")
    parser.add_option("--na_value", action="store", type="string",
                      help="String to use when the part before the divider/ row name is found in some files but not in others. "
                           "If not specified the default of the code meathod will be used. ")
    parser.add_option("--sort", action="store", type="string",
                      help="Allows the output file to be sorted on column_names, row_names, both or none (default). ")
    (options, args) = parser.parse_args()

    if not options.code:
        report_error("No CODE parameter provided")
    execfile(options.code)
    if not options.regex:
        report_error("No REGEX parameter provided")
    if not options.target_path:
        report_error("No TARGET_PATH parameter provided")

    do_walk(source=options.source, regex=options.regex, target_path=options.target_path, 
            verbose=options.verbose, divider=options.divider, sort=options.sort, na_value=options.na_value)

