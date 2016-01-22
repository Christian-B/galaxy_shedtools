import collections
import optparse
import sys

def report_error(error):
    """Prints the error, and exits -1"""
    print error
    sys.stderr.write(error)
    sys.stderr.write("\n")
    sys.stderr.flush()
    sys.exit(1)

def remove_common(names):
    start = names[0]
    end = names[0]
    for name in names:
        while len(start) > 0 and not(name.startswith(start)):
            start = start[:-1]
        while len(end) > 0 and not(name.endswith(end)):
            end = end[1:]
    new_names = []
    for name in names:
        new_name = name[len(start):-len(end)]
        new_names.append(new_name)
    return new_names    

def return_blank():
    return ""

def black_dict():
    return collections.defaultdict(return_blank)

def merge_files(file_paths, names_path, target_path, verbose=False):
    i = -1
    names=[]
    with open(names_path, 'r') as f:
        for line in f:
            line = line.strip()
            if len(line) > 0:
                names.append(line)
    if len(names) != len(file_paths):
        report_error("Found "+str(len(file_paths))+" file_paths but " + names_path + " contains " + str(len(names)) + " lines.")
    new_names = remove_common(names)
    all_values =  collections.defaultdict(black_dict)
    for count, file_path in enumerate(file_paths):
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split("\t")
                if len(parts) == 2:
                    all_values[parts[0]][new_names[count]] = parts[1]
                else: 
                    if verbose:
                        print "ignoring following line from", file_path
                        print line 
    with open(target_path, 'w') as f:
        for name in new_names:
            f.write("\t")
            f.write(name)
        f.write("\n")
        last = len(names)
        for key in all_values:
            f.write(key)
            for name in new_names:
                f.write("\t")
                f.write(all_values[key][name])
            f.write("\n")

if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("-v", "--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    parser.add_option("-f", "--file_path", dest="file_paths", action="append", type="string",
                  help="Path to one of the files to be merged together. Order is relavant and must match names_path.")
    parser.add_option("-n", "--names_path", action="store", type="string",
                  help="Path to file that holds the names of the files to be merged. "
                        "This must be a text files with exactly the same number of lines as file_path apramteres passed in." 
                        "Order is respected.")
    parser.add_option("-t", "--target_path", action="store", type="string",
                  help="Path to write merged data to")
    (options, args) = parser.parse_args()

    if not options.names_path:
        report_error("No NAMES_PATH parameter provided")
    if not options.target_path:
        report_error("No TARGET_PATH parameter provided")
    merge_files(options.file_paths, options.names_path, options.target_path, options.verbose)

