import collections
import optparse  # using optparse as hyrda still python 2.6
import re
import sys


def report_error(error):
    """Prints the error, and exits -1"""
    print error
    sys.stderr.write(error)
    sys.stderr.write("\n")
    sys.stderr.flush()
    sys.exit(1)


def clean_part(part, tab_replace=" "):
    part = part.strip()
    part = part.replace("\t", tab_replace)
    return part


def merge_files(file_paths, file_names, target_path=None, divider="\t", reguired_row_regexes=[], negative_row_regexes=[],
                column_sort=False, row_sort=False, na_value="", tab_replace=" ", verbose=False):
    """
    Merges a list of files into a single tsv file.

    file_paths is a list of paths to the input files

    file_names is an equally long list of names for these files which will be taken as the column names.
    Note: use run_merge_files to shorten the file_names, read them from a file or to use the file_paths as file names

    target_path specifies where the tsv file will be written

    divider is the string to be search for in each line of the input files.
    If found exactly once the part before will be considered a row_name and the part after the data
    Note: If the same row_name is found only the last line is used.

    column_sort and row_sort if set cause the data to be sorted accordingly.

    reguired_row_regexes if provided must be a list of regex patterns. Each row_name must match at least one of these for the row to be included

    negative_row_regexes if provided must be a list of regex patterns. Each row_name must match none of these for the row to be included

    na_value whenever a file does not have data for a row_name

    tab_replace is used to replace any tabs that remain in the row_names and or data after they have been striped of starting and ending whitespace

    verbose if set will cause more verbose infomormation such as lines that do not have the divider
    """
    # Check parameters
    if not file_paths:
        report_error("One or more file_paths parameter must be provided")
    if not target_path:
        report_error("No target_path parameter provided")
    if len(file_names) != len(file_paths):
        report_error("Found " + str(len(file_paths)) + " file_paths but file_names/names_path contains " + str(len(file_names)) + " values.")

    # Read data from file
    all_values = collections.defaultdict(lambda: collections.defaultdict(lambda: na_value))
    for count, file_path in enumerate(file_paths):
        mis_match = 0
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split(divider)
                if len(parts) == 2:
                    key = clean_part(parts[0], tab_replace)
                    value = clean_part(parts[1], tab_replace)
                    all_values[key][file_names[count]] = value
                else:
                    mis_match += 1
                    if verbose:
                        if mis_match < 5:
                            print "ignoring following line from", file_path
                            print line
        if mis_match > 0:
            print "In file " + file_path + " " + str(mis_match) + " lines did not have 1 divider (" + divider + ") "

    # rows names are all the keys from the data found
    row_names = all_values.keys()

    # check row_names against the regex rules
    if reguired_row_regexes or negative_row_regexes:
        ok_names = []
        if reguired_row_regexes:
            reguired_res = []
            for reguired_row_regex in reguired_row_regexes:
                reguired_res.append(re.compile(reguired_row_regex))
        if negative_row_regexes:
            negative_res = []
            for negative_row_regex in negative_row_regexes:
                negative_res.append(re.compile(negative_row_regex))
        for row_name in row_names:
            if reguired_row_regexes:
                ok = False
                for reguired_re in reguired_res:
                    if reguired_re.search(row_name):
                        ok = True
            else:
                ok = True
            if negative_row_regexes and ok:
                for negative_re in negative_res:
                    if negative_re.search(row_name):
                        ok = False
            if ok:
                ok_names.append(row_name)
        row_names = ok_names

    # Sort keys if required
    if column_sort:
        file_names = sorted(file_names)
    if row_sort:
        row_names = sorted(row_names)

    # Write the data
    with open(target_path, 'w') as f:
        for name in file_names:
            f.write("\t")
            f.write(name)
        f.write("\n")
        for key in row_names:
            f.write(key)
            for name in file_names:
                f.write("\t")
                f.write(all_values[key][name])
            f.write("\n")


# To run the method shortening and if reguried getting file_names or file_paths use this section


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


# See merge_files method for kwargs

def run_merge_files(file_paths=[], file_names=[], files_path=None, **kwargs):
    """
    Handles file paths and file names before calling merge-files.

    file_paths is a list of the paths to be merge together.

    file_names is a list of names that will be shortened and then used for column names.
    The lenght of file_names must match file_paths, and the order is relevant to file_names.

    files_path if provided will the path of files paths and or file names to be used if they are not supplied directly.

    The kwargs arguements are defined by merge_files method which is called at the end of this method.
    """

    # read file_paths and/or file_names if required
    if files_path:
        if file_paths:
            print "Using parameters file_paths and not the ones in files_path"
        else:
            file_paths = read_names(files_path)
        if file_names:
            print "Using parameters file_names and not the ones in files_path"
        else:
            file_names = read_names(files_path)

    # use file_paths if no file_names provided
    if not file_names:
        file_names = file_paths

    #To avoid wide column names the start and end text shared by all names is removed
    file_names = remove_common(file_names)

    #Call the name merge_files method
    merge_files(file_paths, file_names, **kwargs)


# From here on down is the code if this is being run from the command line including galaxy.


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
    end = 0
    # tab = 9
    # | = 124
    while True:
        start = s.find("__", end)
        if start == -1:
            return s
        end = s.find("__", start + 2) + 2
        if end == 1:
            return s
        part = s[start + 2: end - 2]
        if part == "":
            # start + 2 to leave one set of __ behind
            s = s[:start + 2] + s[end:]
            end = start + 2
        else:
            try:
                ascii = int(part)
                s = s[:start] + chr(ascii) + s[end:]
                end = start - 1  # (2) __ removed before start and one character added after so -1
            except ValueError:
                pass
    return s


def read_names(names_path):
    names = []
    with open(names_path, 'r') as f:
        for line in f:
            line = line.strip()
            if len(line) > 0:
                names.append(line)
    return names


if __name__ == '__main__':

    parser = optparse.OptionParser()
    parser.add_option("--verbose", action="store_true", default=False,
                      help="If set will generate output of what the tool is doing.")
    parser.add_option("--file_path", action="append", type="string",
                      help="Path to one of the files to be merged together.")
    parser.add_option("--file_name", action="append", type="string",
                      help="Names for the files. To be used to generate column names. "
                           "Order and size are relavant and must match file_path. "
                           "Optional: Can also be provides as a path to a file using names_path "
                           "If neither are provide the file_paths are used.")
    parser.add_option("--files_path", action="store", type="string",
                      help="Path to file that holds the file_paths and or file_names. "
                           "Ignored if file_paths and or file_names are provided directly.")
    parser.add_option("--target_path", action="store", type="string",
                      help="Path to write merged data to")
    parser.add_option("--divider", action="store", type="string",
                      help="Divider between key and value. Special symbols can be entered using galaxy code or __acsii__ (for __ use ____). "
                           "Note: After splitiing on divider both parts will be trimmed for whitespace.")
    parser.add_option("--na_value", action="store", type="string",
                      help="String to use when the part before the divider/ row name is found in some files but not in others. "
                           "Default if not specified is a blank. ")
    parser.add_option("--column_sort", action="store_true", default=False,
                      help="If set will sort the columns based on shortened file names.")
    parser.add_option("--row_sort", action="store_true", default=False,
                      help="If set will sort the row based on shortened file names.")
    parser.add_option("--reguired_row_regex", action="append", type="string",
                      help="If provided, only rows whose cleaned name matches one or more of these regex rules will be kept. "
                           "Special symbols can be entered using galaxy code or __acsii__ (for __ use ____) ")
    parser.add_option("--negative_row_regex", action="append", type="string",
                      help="If provided, only rows whose cleaned name matches none of these regex rules will be kept. "
                           "Special symbols can be entered using galaxy code or __acsii__ (for __ use ____) ")
    parser.add_option("--tab_replace", action="store", type="string", default=" ",
                      help="Value to beinserted in data including column and row names whenever a tab is found. "
                           "Default is a single space.")
    (options, args) = parser.parse_args()

    if not options.divider:
        report_error("No divider parameter provided")
    clean_divider = remove_symbols(options.divider)
    if options.verbose and (clean_divider != options.divider):
        print "divider", options.divider, "cleaned to", clean_divider
    options.divider = clean_divider

    if not options.na_value:
        if options.verbose:
            print "As no na-value provided a blank space will be used"
        options.na_value = ""

    if not options.tab_replace:
        options.tab_replace = " "

    if not options.reguired_row_regex:
        options.reguired_row_regex = []
    for i, rule in enumerate(options.reguired_row_regex):
        clean_rule = remove_symbols(rule)
        if options.verbose and (clean_rule != rule):
            print "reguired_row_regex", rule, "cleaned to", clean_rule
        options.reguired_row_regex[i] = clean_rule

    if not options.negative_row_regex:
        options.negative_row_regex = []
    for i, rule in enumerate(options.negative_row_regex):
        clean_rule = remove_symbols(rule)
        if options.verbose and (clean_rule != rule):
            print "negative_row_regex", rule, "cleaned to", clean_rule
        options.negative_row_regex[i] = remove_symbols(rule)

    run_merge_files(file_paths=options.file_path, file_names=options.file_name, files_path=options.files_path,
                    target_path=options.target_path, verbose=options.verbose, divider=options.divider,
                    column_sort=options.column_sort, row_sort=options.row_sort, na_value=options.na_value, tab_replace=options.tab_replace,
                    reguired_row_regexes=options.reguired_row_regex, negative_row_regexes=options.negative_row_regex)
