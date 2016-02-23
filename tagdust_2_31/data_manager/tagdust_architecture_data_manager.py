#!/usr/bin/env python

import json
import optparse
import os.path

def _add_data_table_entry( data_manager_dict, data_table_name, data_table_entry ):
    data_manager_dict['data_tables'] = data_manager_dict.get( 'data_tables', {} )
    data_manager_dict['data_tables'][ data_table_name ] = data_manager_dict['data_tables'].get( data_table_name, [] )
    data_manager_dict['data_tables'][ data_table_name ].append( data_table_entry )
    return data_manager_dict


def get_param(name, params, default=None,  check_tab=True):
    value = params.get(name)
    print name, value
    return check_param(name, value, default=default, check_tab=check_tab)


def check_param(name, value, default=None,  check_tab=True):
    if value in [ None, '', '?' ]:
        if default:
            print "Using {0} for {1} as no value provided".format( default, name )
            value = default
        else:
            raise Exception( '{0} is not a valid {1}. You must specify a valid {1}.'.format( value, name ) )
    if check_tab and "\t" in value:
        raise Exception( '{0} is not a valid {1}. It may not contain a tab because these are used as seperators by galaxy .'.format( value, name ) )
    return value


def createFileBasedOnHmm(hmms):
    file_name = ""
    bar_code = "no"
    for hmm in hmms:
        block = hmm["block"]
        if not (block[0] in ['R','O','G','B','F','S','P']):
            raise Exception( "hmm block {0} is not a valid. It must start with one of  ['R','O','G','B','F','S','P'].".format( block ) )
        if block[0] == 'B':
            bar_code = "yes"
        if block[1] != ':':
            raise Exception( "hmm block {0} is not a valid. The second character must be ':'".format( block ) )
        if "\t" in hmm:
            raise Exception( "hmm block {0} is not a valid. It may not contain a tab, due to galaxy using tabs as seperators".format( block ) )
        file_name = file_name + block + "_"
    file_name = file_name[:-1] + ".txt"
    return bar_code, file_name


def get_path(galaxy_tool_dir, file_name):
    file_path =  os.path.join(galaxy_tool_dir, "tagdust_architecture")
    if os.path.exists(file_path):
        if os.path.isfile(file_path):
            raise Exception( "Found a file at {0}, but expecting a directory there".format( file_path ) )
    else:
        os.mkdir(file_path)
    return os.path.join(file_path, file_name)


def writeHmm(hmms, file_path):
    with open( file_path, 'w' ) as output_file:
        output_file.write("./tagdust") 
        for i, hmm in enumerate( hmms, 1 ):
            output_file.write(" ")
            output_file.write(str(-i))
            output_file.write(" ")
            output_file.write(hmm["block"])

def main():

    #Parse Command Line
    parser = optparse.OptionParser()
    parser.add_option( '--data_table_name', action='store', type="string", default=None, help='path' )
    parser.add_option( '--json_output_file', action='store', type="string", default=None, help='path' )
    (options, args) = parser.parse_args()

    data_table_name = check_param("data_table_name", options.data_table_name)
    json_output_file = check_param("json_output_file", options.json_output_file, check_tab=False)

    param_dict = json.loads( open( json_output_file ).read() )
    params = param_dict.get("param_dict")
    print "input params:"
    print params

    hmms = get_param("hmms", params)
    galaxy_tool_dir = get_param("GALAXY_DATA_INDEX_DIR", params)

    data_table_entry = {}

    data_table_entry["barcode"], file_name = createFileBasedOnHmm(hmms)
    data_table_entry["path"] =  get_path(galaxy_tool_dir, file_name)
    writeHmm(hmms, data_table_entry["path"])

    basename = os.path.basename(data_table_entry["path"])
    filename = os.path.splitext(basename)[0]
    data_table_entry["name"] = get_param("name", params, default=filename)
    data_table_entry["value"] = get_param("value", params, default=data_table_entry["name"])
    data_table_entry["dbkey"] = get_param("dbkey", params, default=data_table_entry["value"])

    data_manager_dict = {}
    _add_data_table_entry( data_manager_dict, data_table_name, data_table_entry )

    print "output:"
    print data_manager_dict
    # save info to json file
    with open( json_output_file, 'wb' ) as output_file:
        output_file.write( json.dumps( data_manager_dict ) )
        output_file.write( "\n" )


if __name__ == "__main__": 
    main()
