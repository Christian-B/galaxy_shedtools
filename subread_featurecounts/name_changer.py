#!/usr/bin/env python

import optparse
import os.path

def fix_header_line(header_line, new_names):
    print "header line length",(len(header_line))
    header_parts = header_line.split("\t")
    print "header parts length",(len(header_parts))
    if len(header_parts) < 7:
        raise Exception( "Only found {0} columns in second (header) line expected at least 7.".format( len(header_parts) ) )
    data_headers = header_parts[:6]
    if data_headers != ["Geneid","Chr","Start","End","Strand","Length"]:
        #raise Exception("Unexpected start to second (header) line Found: {0}".format(header_line[:1000]))
        raise Exception("Unexpected start to second (header) line Found: ")
    new_header = "Geneid\tChr\tStart\tEnd\tStrand\tLength"
    file_headers = header_parts[6:]
    if len(file_headers) != len(new_names):
        raise Exception( "Found {0} file columns in header line, but {1} new_name paramters provided.".format( len(file_headers), len(new_names)))
    for i in range(len(file_headers)):
        new_header+= "\t"
        new_header+= new_names[i]
    new_header+= "\n"
    return new_header

def main():
    #Parse Command Line
    parser = optparse.OptionParser()
    parser.add_option( "--raw_count_file", action="store", type="string", default=None, help="path to file original with the counts" )
    parser.add_option( "--fixed_count_file", action="store", type="string", default=None, help="new path for renamaned counts file" )
    parser.add_option( "--names_file", action="store", type="string", default=None, help="path to file which contains the names." )
    parser.add_option( "--new_name", action="append", type="string", default=None, 
                      help="Names to be used. Must be the same length as in the raw_count_file" )
    parser.add_option( "--names_prefix", action="store", type="string", default="", help="Prefix to add in from of every name." )

    (options, args) = parser.parse_args()

    if not os.path.exists(options.raw_count_file):
        parser.error( "Unable to find raw_count_file {0}.".format( options.raw_count_file ) )
    if options.names_file:
        if options.new_name:
             parser.error( "names_file parameter clashes with new_names paramter(s)")
        if not os.path.exists(options.names_file):
            parser.error( "Unable to find names_file {0}.".format( options.names_file ) )
        new_names = []
        with open( options.names_file, "r" ) as names_file:
            for line in names_file:
                new_names.append(line.strip())
    else:
        if not options.new_name:
            parser.error( "No names_file or new_name paraters provided.")
        new_names = options.new_name

    for i in range(len(new_names)):
        new_names[i] = options.names_prefix + new_names[i]
    print "Changing column names to ",new_names

    with open( options.raw_count_file, "r" ) as input_file:
        with open( options.fixed_count_file, "w" ) as output_file:
            job_line = input_file.readline()
            #print "job line length",(len(job_line))
            header_line = fix_header_line(input_file.readline(), new_names)
            #print header_line
            output_file.write(header_line)
            #next_line = input_file.readline()
            #print "next line length",(len(next_line))
            
            for line in input_file:
                output_file.write(line)

if __name__ == "__main__": 
    main()
