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
            start = start[: -1]
        while len(end) > 0 and not(name.endswith(end)):
            end = end[1:]
    new_names = []
    for name in names:
        if len(end) > 0:
            new_name = name[len(start): -len(end)]
        else:
            new_name = name[len(start):]
        new_names.append(new_name)
    return new_names


def remove_symbols(s):
    if s.find("__") == -1:
        return s
    # Patterns used by Galaxy
    s = s.replace("__cb__", ']')
    s = s.replace("__cc__", '}')
    s = s.replace("__dq__", '"')
    s = s.replace("__lt__", '<')
    s = s.replace("__gt__", '>')
    s = s.replace("__ob__", '[')
    s = s.replace("__oc__", '{')
    s = s.replace("__sq__", "'")
    # Patterns added by Christian
    s = s.replace("__in__", '%in%')
    s = s.replace("__not__", '!')
    end = -2
    # tab = 9
    # | = 124
    while True:
        start = s.find("__", end + 2) + 2
        if start == 1:
            return s
        end = s.find("__", start)
        if end == -1:
            return s
        part = s[start: end]
        try:
            ascii = int(part)
            s = s.replace("__" + part + "__", chr(ascii))
            end = -2
        except ValueError:
            pass
    return s


def clean_part(part):
    part = part.strip()
    part = part.replace("\t", "__9__")
    return part


def merge_files(file_paths, names_path, target_path, verbose=False, divider="\t", sort = None, na_value=""):
    if sort:
        if sort == "column_names":
            column_sort = True
            row_sort = False
        elif sort == "row_names":
            column_sort = False
            row_sort = true
        elif sort == "both":
            column_sort = True
            row_sort = True
        elif sort == "none":
            column_sort = False
            row_sort = False
        else:
            report_error("Unexpected value: " + sort + " for sort parameter. Legeal values are: column_names, row_names, both or none")
    else:
        column_sort = False
        row_sort = False

    names = []
    with open(names_path, 'r') as f:
        for line in f:
            line = line.strip()
            if len(line) > 0:
                names.append(line)
    if len(names) != len(file_paths):
        report_error("Found " + str(len(file_paths)) + " file_paths but " + names_path + " contains " + str(len(names)) + " lines.")
    new_names = remove_common(names)
    print new_names
    clean_divider = remove_symbols(divider)
    all_values = collections.defaultdict(lambda: collections.defaultdict(lambda: na_value))
    for count, file_path in enumerate(file_paths):
        mis_match = 0
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split(clean_divider)
                if len(parts) == 2:
                    key = clean_part(parts[0])
                    value = clean_part(parts[1])
                    all_values[key][new_names[count]] = value
                else:
                    mis_match+= 1
                    if verbose:
                        if mis_match < 5:
                            print "ignoring following line from", file_path
                            print line
        if mis_match > 0:
            print "In file " + file_path + " " + str(mis_match) + " lines did not have 1 divider (" + clean_divider + ") " + divider

    if column_sort:
        new_names = sorted(new_names)
    if row_sort:
        row_names = sorted(all_values.keys())
    else:
        row_names = all_values.keys()

    with open(target_path, 'w') as f:
        for name in new_names:
            f.write("\t")
            f.write(name)
        f.write("\n")
        for key in row_names:
            f.write(key)
            for name in new_names:
                f.write("\t")
                f.write(all_values[key][name])
            f.write("\n")

if __name__ == '__main__' and not 'parser' in locals():

    parser = optparse.OptionParser()
    parser.add_option("--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    parser.add_option("--file_path", dest="file_paths", action="append", type="string",
                      help="Path to one of the files to be merged together. Order is relavant and must match names_path.")
    parser.add_option("--divider", action="store", type="string",
                      help="Divider between key and value. Special symbols can be entered using galaxy code or __acsii__ . "
                           "Note: After splitiing on divider both parts will be trimmed for whitespace.")
    parser.add_option("--names_path", action="store", type="string",
                      help="Path to file that holds the names of the files to be merged. "
                           "This must be a text files with exactly the same number of lines as file_path paramtere passed in."
                           "Output order depends on sort value.")
    parser.add_option("--na_value", action="store", type="string",
                      help="String to use when the part before the divider/ row name is found in some files but not in others. "
                           "Default if not specified is a blank. ")
    parser.add_option("--sort", action="store", type="string",
                      help="Allows the output file to be sorted on column_names, row_names, both or none (default). ")
    parser.add_option("--target_path", action="store", type="string",
                      help="Path to write merged data to")
    (options, args) = parser.parse_args()

    if not options.names_path:
        report_error("No NAMES_PATH parameter provided")
    if not options.target_path:
        report_error("No TARGET_PATH parameter provided")
    if not options.na_value:
        if options.verbose:
            print "As no na-value provided a blank space will be used"
        options.na_value = ""

    merge_files(options.file_paths, options.names_path, options.target_path, options.verbose, options.divider, options.sort, options.na_value)
