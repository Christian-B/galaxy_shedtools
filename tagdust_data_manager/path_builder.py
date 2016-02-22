#!/usr/bin/env python

import json
import optparse
import os.path

def _add_data_table_entry( data_manager_dict, data_table_name, data_table_entry ):
    data_manager_dict['data_tables'] = data_manager_dict.get( 'data_tables', {} )
    data_manager_dict['data_tables'][ data_table_name ] = data_manager_dict['data_tables'].get( data_table_name, [] )
    data_manager_dict['data_tables'][ data_table_name ].append( data_table_entry )
    return data_manager_dict


def check_param(name, value, check_tab=True):
    if value in [ None, '', '?' ]:
        raise Exception( '{0} is not a valid {1}. You must specify a valid {1}.'.format( value, name ) )
    if check_tab and "\t" in value:
        raise Exception( '{0} is not a valid {1}. It may not contain a tab.'.format( value, name ) )
    return value


def main():

    #value = "test_value"
    #name = "test_name"
    #print '{0} other {1} more{0}'.format(value, name )
    #print '{0} is not a valid {1}. It may not contain a tab.'.format( value, name )

    #Parse Command Line
    parser = optparse.OptionParser()
    parser.add_option( '--value', action='store', type="string", default=None, help='value' )
    parser.add_option( '--dbkey', action='store', type="string", default=None, help='dbkey' )
    parser.add_option( '--name',  action='store', type="string", default=None, help='name' )
    parser.add_option( '--path', action='store', type="string", default=None, help='path' )
    parser.add_option( '--data_table_name', action='store', type="string", default=None, help='path' )
    parser.add_option( '--json_output_file', action='store', type="string", default=None, help='path' )
    (options, args) = parser.parse_args()
 
    value = check_param("value", options.value)
    dbkey = check_param("dbkey", options.dbkey)
    name = check_param("name", options.name)
    path = check_param("path", options.path, check_tab=False)
    if not os.path.exists(path):
        raise Exception( 'Unable to find path {0}.'.format( path ) )
    data_table_name = check_param("data_table_name", options.data_table_name)
    json_output_file = check_param("json_output_file", options.json_output_file, check_tab=False)

    params = json.loads( open( json_output_file ).read() )
    print params

    data_manager_dict = {}
    data_table_entry = dict( value=value, dbkey=dbkey, name=name, path=path )
    _add_data_table_entry( data_manager_dict, data_table_name, data_table_entry )

    #save info to json file
    with open( json_output_file, 'wb' ) as output_file:
        output_file.write( json.dumps( data_manager_dict ) )
        output_file.write( "\n" )

if __name__ == "__main__": 
    main()
