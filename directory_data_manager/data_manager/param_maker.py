#!/usr/bin/env python
import json

def main():
    params = {}
    params["name"] = "A Name"
    params["value"] = "A Value"
    params["dbkey"] = "the key"
    params["original_extension"] = "fastq.gz"
    params["galaxy_extension"] = "fastqsanger"
    params["decompress"] = "Yes"
    params["path"] = "/home/christian/test"
    print "params", params

    param_dict = {}
    param_dict["param_dict"] = params
    #save info to json file
    with open( "test.json", 'wb' ) as output_file:
        output_file.write( json.dumps( param_dict ) )
        output_file.write( "\n" )

if __name__ == "__main__": 
    main()
