This repository contains code to merge multile files.

# File Finder
file_finder.py will walk through all the directories in the source directory looking for files that match the regex pattern.

If the optional target_path is provided the file_paths will be written to that file, otherwise they are just printed to standard out.

# Key methods
The key method is do_walk(source, regex, onerror=None, followlinks=False, verbose=True) which will return a list of file paths

### Command line Example

    python file_finder.py --source=test-data --regex=htseq_count.txt --target_path=test-data/names.txt 

# merge_files.py 
Merges a list of files into a single tsv file.

file_path(s) is a list of paths to the input files

file_name(s) is an equally long list of names for these files which will be taken as the column names.
File names are shortened by removing the common start and end bits of all names.
(Except is merge_files method call directly)

files_path if provided will the path of files paths and or file names to be used if they are not supplied directly.

target_path specifies where the tsv file will be written

divider is the string to be search for in each line of the input files. 
If found exactly once the part before will be considered a row_name and the part after the data
Note: If the same row_name is found only the last line is used.
See:  Special charaters

column_sort and row_sort if set cause the data to be sorted accordingly.

reguired_row_regexes if provided must be a list of regex patterns. Each row_name must match at least one of these for the row to be included. 
See:  Special charaters

negative_row_regexes if provided must be a list of regex patterns. Each row_name must match none of these for the row to be included. 
See:  Special charaters

na_value whenever a file does not have data for a row_name

tab_replace is used to replace any tabs that remain in the row_names and or data after they have been striped of starting and ending whitespace

verbose if set will cause more verbose infomormation such as lines that do not have the divider

## Special charaters
<pre>
The command line makes if difficult to use many specially characters.

Therefor Galaxy replaces some of these with a __*__ replacement string.

ascii  char   code
 34     "     __dq__
 35     #     __pd__
 39     '     __sq__
 60     <     __lt__
 62     >     __gt__
 64     @     __at__
 91     [     __ob__
 93     ]     __cb__
123     {     __oc__
125     }     __cc__

For others Galaxy just inserts an X.  For these use you can use the format __ascii__

This includes all charaacters below ascii 31 above ascii 126 and the following:

ascii  char   code
  9    tab    __9__
 36     $     __36__
 37     %     __37__
 38     &     __38__
 59     ;     __59__
 92     \     __92__
 96     `     __96__
124     |     __124__
126     ~     __126__

All of these, including any __ascii__ combination will be converted back by the tool before compiling the regex pattern.

As __ (2 underscores) is used here: ____ (4 underscores) will be read as __ (2 underscores)

So for example to use either a or b  (a|b) enter (a__124__b) 

The regex pattern to detect two underscores at the end __$ needs to be entered as __36______
</pre>

## Key methods
The key method is merge_files(file_paths,  file_names, target_path, divider="\t", reguired_row_regexes=[], negative_row_regexes=[], column_sort=False, row_sort=False, na_value="", tab_replace=" ", verbose=False)

merge_files will take file_paths and file_names verbatum.

This is supported by run_merge_files(file_paths=[], file_names=[], files_path=None, **kwargs)

run_merge_files will read file_paths and file_names from the file pointed to be files_path if not provided

If no file_names are provided the file_paths are used.

The file_names are shortened by removing any 

### Command line Example
    python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt --files_path=test-data/names.txt --target_path=test-data/merged.tsv  --divider __9__ 

    python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt  --target_path=test-data/merged.tsv  --divider __9__ 

    python merge_files.py --files_path=test-data/names.txt --target_path=test-data/merged.tsv  --divider __9__ 

    python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt  --target_path=test-data/merged_regex.tsv  --divider __9__ --reguired_row_regex 1 --reguired_row_regex __50__ --negative_row_regex __56__ --negative_row_regex 9 --row_sort --verbose

    python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt --names_path=test-data/names.txt --target_path=test-data/sorted_merged.tsv  --divider __9__ --column_sort --row_sort

    python merge_files.py  --file_path=test-data/C43_TAAGGCGA-CTAAGCCT_L003_/Log.final.out --file_path=test-data/C08_CGTACTAG-CTCTCTAT_L003_/Log.final.out --file_path=test-data/C62_GGACTCCT-TATCCTCT_L003_/Log.final.out --names_path=test-data/log_names.txt --target_path=test-data/log_merged.tsv  --divider __124__ --na_value "0" 

    python merge_files.py  --file_path=test-data/C43_TAAGGCGA-CTAAGCCT_L003_/Log.final.out --file_path=test-data/C08_CGTACTAG-CTCTCTAT_L003_/Log.final.out --file_path=test-data/C62_GGACTCCT-TATCCTCT_L003_/Log.final.out --names_path=test-data/log_names.txt --target_path=test-data/log_merged_no_na.tsv  --divider __124__ 

# Combining File Finder and merge_files.py

The multi_merge_walker has been retired instead the recommended method is to two two steps.

1. Is file_finder to get the list of files

2. Use merge_files.py to generate the tsv summary

## Galaxy
planemo lint  merge_files.xml

planemo test --galaxy_root=/home/christian/galaxy  --no_cleanup   merge_files.xml

built doing:
tar --create --file=merge_files.tar --gzip --verbose merge_files.xml merge_files.py test-data/*

