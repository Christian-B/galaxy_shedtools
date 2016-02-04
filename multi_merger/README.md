This repository contains code to merge multile files.

# Walker
walking_multi_merger.py will walk through all the directories in the source directory looking for files that match the regex pattern.
Every time a matching file is found its full path is added to a temporary names files, and the path is also added to a list of file paths.

Once all the files and names have been found the merge_files(file_paths, names_path, target_path, divider) method is called in the code pointed to by the code parameter.

The divider parameter is optional and only passed to merge_files if required.  For symbols that are hard to pass in a command line use \_\_ascii\_\_ for example \_\_9\_\_ is tab and \_\_124\_\_ is the horizontal line.

### Example

    python walking_multi_merger.py --source=test-data --code=merge_files.py --regex=htseq_count.txt --target_path=test-data/merged.tsv --divider __9__ --verbose

    python walking_multi_merger.py --source=test-data --code=merge_files.py --regex=Log.final.out --target_path=test-data/log_merged.tsv --divider __124__ --verbose


# merge_files.py 
Implements merge_files(file_paths, names_path, target_path)

The list of file names is read from the file pointed to by names_path. These are assumed to be the names of the files in file_path so must match in length

The list of names is shortened by removing and start or end text common to all names

All files in file_path are then read looking for lines with exactly one tab.

These lines are then split into two to polulate a dictionary of dictionaies. Where the first key is part before the tab and the second key is the name.

This dictionary is then writen out as a tab seperated file such that the coumn names are the unique parts of the names and the row names are the first part of each line.

## Directly callable
This tool is directly callable but this was many implemented for the galaxy tool.

### Example
    python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt --names_path=test-data/names.txt --target_path=test-data/merged.tsv  --divider __9__ 

    python merge_files.py  --file_path=test-data/C43_TAAGGCGA-CTAAGCCT_L003_/Log.final.out --file_path=test-data/C08_CGTACTAG-CTCTCTAT_L003_/Log.final.out --file_path=test-data/C62_GGACTCCT-TATCCTCT_L003_/Log.final.out --names_path=test-data/log_names.txt --target_path=test-data/log_merged.tsv  --divider __124__ 




## Galaxy
planemo test --galaxy_root=/home/christian/galaxy  --no_cleanup   merge_files.xml

built doing:
tar --create --file=merge_files.tar --gzip --verbose merge_files.xml merge_files.py test-data/*

