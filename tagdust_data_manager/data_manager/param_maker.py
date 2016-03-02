#!/usr/bin/env python
import json

def main():
    params = {}
    params["name"] = "A Name"
    params["value"] = "A Value"
    params["dbkey"] = "the key"
    params["hmms"] = [{u'__index__': u'0', u'block': u'F:NNN'},{u'__index__': u'1', u'block': u' B:GTA,AAA'}]
    params["GALAXY_DATA_INDEX_DIR"] = "/home/christian/Dropbox/Manchester/galaxy_shed_tools/tagdust_data_manager/data_manager"
    print "params", params

    param_dict = {}
    param_dict["param_dict"] = params
    #save info to json file
    with open( "test.json", 'wb' ) as output_file:
        output_file.write( json.dumps( param_dict ) )
        output_file.write( "\n" )

if __name__ == "__main__": 
    main()
