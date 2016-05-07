#!/usr/bin/env python

import optparse
import os.path


def fix_header_line(start_header, header_line, new_names):
    header_parts = header_line.split("\t")
    if len(header_parts) <= len(start_header):
        raise Exception("Only found {0} columns in second (header) line expected at least {1}.".format(len(header_parts), (len(start_header) + 1)))
    data_headers = header_parts[:len(start_header)]
    if data_headers != start_header:
        raise Exception("Unexpected start to second (header) line Found: ")
    new_header = "\t".join(start_header)
    file_headers = header_parts[len(start_header):]
    if len(file_headers) != len(new_names):
        raise Exception("Found {0} file columns in header line, but {1} new_name paramters provided.".format(len(file_headers), len(new_names)))
    for i in range(len(file_headers)):
        new_header += "\t"
        new_header += new_names[i]
    new_header += "\n"
    return new_header


def clean_names(prefix, old_names):
    if len(old_names) > 1:
        shared_start = old_names[0].strip()
        shared_ends = old_names[0].strip()
        for name in old_names:
            clean = name.strip()
            while len(shared_start) > 0 and (not clean.startswith(shared_start)):
                shared_start = shared_start[:-1]
            while len(shared_ends) > 0 and (not clean.endswith(shared_ends)):
                shared_ends = shared_ends[1:]
        start = len(shared_start)
        end = 0 - len(shared_ends)
    else:
        start = 0
        end = 0
    new_names = []
    if end < 0:
        for name in old_names:
            new_names.append(prefix + name.strip()[start:end])
    else:
        for name in old_names:
            new_names.append(prefix + name.strip()[start:])
    return new_names


def main():
    #Parse Command Line
    parser = optparse.OptionParser()
    parser.add_option("--raw_count_file", action="store", type="string", default=None, help="path to file original with the counts")
    parser.add_option("--fixed_count_file", action="store", type="string", default=None, help="new path for renamaned counts file")
    parser.add_option("--raw_summary_file", action="store", type="string", default=None, help="path to file original with the summary")
    parser.add_option("--fixed_summary_file", action="store", type="string", default=None, help="new path for renamaned summary file")
    parser.add_option("--names_file", action="store", type="string", default=None, help="path to file which contains the names.")
    parser.add_option("--new_name", action="append", type="string", default=None,
                      help="Names to be used. Must be the same length as in the raw_count_file")
    parser.add_option("--names_prefix", action="store", type="string", default="", help="Prefix to add in from of every name.")

    (options, args) = parser.parse_args()

    if not os.path.exists(options.raw_count_file):
        parser.error("Unable to find raw_count_file {0}.".format(options.raw_count_file))
    if options.names_file:
        if options.new_name:
            parser.error("names_file parameter clashes with new_names paramter(s)")
        if not os.path.exists(options.names_file):
            parser.error("Unable to find names_file {0}.".format(options.names_file))
        new_names = []
        with open(options.names_file, "r") as names_file:
            for line in names_file:
                new_names.append(line.strip())
        new_names = clean_names(options.names_prefix, new_names)
    else:
        if not options.new_name:
            parser.error("No names_file or new_name paraters provided.")
        new_names = options.new_name

    print "Changing column names to ", new_names

    with open(options.raw_count_file, "r") as input_file:
        with open(options.fixed_count_file, "w") as output_file:
            input_file.readline()  # job line
            start_header = ["Geneid", "Chr", "Start", "End", "Strand", "Length"]
            header_line = fix_header_line(start_header, input_file.readline(), new_names)
            output_file.write(header_line)
            for line in input_file:
                output_file.write(line)

    with open(options.raw_summary_file, "r") as input_file:
        with open(options.fixed_summary_file, "w") as output_file:
            start_header = ["Status"]
            header_line = fix_header_line(start_header, input_file.readline(), new_names)
            output_file.write(header_line)
            for line in input_file:
                output_file.write(line)


if __name__ == "__main__":
    main()
