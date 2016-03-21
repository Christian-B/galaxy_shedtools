#!/usr/bin/env python

import gzip
import json
import optparse  # using optparse as hydra still python 2.6
import os.path
import shutil

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

def check_extension(extension):
    extension = extension.strip()
    if extension[0] == ".":
        extension = extension[1:]
    return extension


def check_path(path, original_extension):
    files = os.listdir(path)
    check = "." + original_extension
    for a_file in files:
        if a_file.endswith(check):
            return True
    raise Exception( 'path {0} does not contain any files ending with {1}'.format( path, check ) )


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

    data_table_entry = {}
    data_table_entry["original_extension"] = check_extension(get_param("original_extension", params))
    data_table_entry["galaxy_extension"] = check_extension(get_param("galaxy_extension", params))
    data_table_entry["decompress"] = get_param("decompress", params)
    if not (data_table_entry["decompress"] in ["No","Yes"]):
        raise Exception( "Only legal values for dcompress are No and Yes." )
    data_table_entry["path"] = get_param("path", params)
    check_path(data_table_entry["path"], data_table_entry["original_extension"])
 
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
