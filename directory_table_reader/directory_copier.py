import gzip
import optparse  # using optparse as hydra still python 2.6
import os.path
import shutil
import sys

def report_error(*args):
    sys.stderr.write(' '.join(map(str,args)) + '\n')
    sys.stderr.flush()
    sys.exit(1)


def check_pattern_get_new_name(a_file, ending, options):
    if options.start:
        if not(a_file.startswith(options.start)):
            return None
    if options.last:
        if ending[0] == ".":
            last = options.last + ending
        else:
            if options.last[-1] == ".":
                last = options.last + ending
            else:
                last = options.last + "." + ending
        if not(a_file.endswith(last)):
            return None
    if options.new_ending:
        name = a_file[:-len(ending)]
        if options.new_ending[0] ==".":
            if name[-1] == ".":
                name = name[:-1]
        return name + options.new_ending
    if options.decompress:
        if a_file.endswith(".gz"):
            return a_file[:-3]
    return a_file


def check_and_get_new_name(a_file, options):
    for ending in options.endings:
        if a_file.endswith(ending):
            return check_pattern_get_new_name (a_file, ending, options)
    return None


def link(a_file, new_name, path):
    file_path = os.path.join(os.path.realpath(path), a_file)
    sym_path = os.path.join(os.path.realpath("output"), new_name)
    #if not(os.path.exists(sym_path)):
    os.link(file_path, sym_path)


def decompress(a_file, new_name, path):
    file_path = os.path.join(os.path.realpath(path), a_file)
    target_path = os.path.join(os.path.realpath("output"), new_name)
    with gzip.open(file_path, 'rb') as f_in, open(target_path, 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)


def copy_and_link(path, options):
    os.mkdir("output")
    with open(options.list, 'w') as list_file:
        files = os.listdir(path)
        files.sort()
        for a_file in files:
            new_name = check_and_get_new_name(a_file, options)
            if new_name:
                list_file.write(new_name)
                list_file.write("\n")
                if options.decompress:
                    if a_file.endswith(".gz"):
                        decompress(a_file, new_name,path)
                    else:
                        link(a_file, new_name, path)
                elif options.link:
                    link(a_file, new_name, path)


if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option("--path", action="store", type="string",
                      help="Path of directory to check. ")
    parser.add_option("--ending", action="append", type="string", dest="endings",
                      help="Ending that can be listed and if requested linked or decompressed. ")
    parser.add_option("--start", action="store", type="string",
                      help="String that must be at the start of the file name ")
    parser.add_option("--last", action="store", type="string",
                      help="String that must be the last bit of the file name before the endings")
    parser.add_option("--new_ending", action="store", type="string", 
                      help="New ending to replace any previous ending in list and if required links or decompressions. Note: If not set decompression will auto remove the compressioned part of the ending")
    #parser.add_option("--regex", action="store", type="string",
    #                  help="Regex pattern the file name (less . ending) must match before the endings")
    parser.add_option("--list", action="store", type="string",
                      help="Path to where all files should be listed. ")
    parser.add_option("--link", action="store_true", default=False,
                      help="If set will cause links to be added in output directory. ")
    parser.add_option("--decompress", action="store_true", default=False,
                      help="If set will cause gz files to be decompressed or if not a supported decompression ending linked.")
    (options, args) = parser.parse_args()


    path = options.path.strip()
    if path[-1] != '/':
        path = path + "/"
    copy_and_link(path, options)

