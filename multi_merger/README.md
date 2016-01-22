This repository contains code to merge multile files.

# Walker
walking_multi_merger.py will walk through all the directories in the source directory looking for files that match the regex pattern.
Every time a matching file is found its full path is added to a temporary names files, and the path is also added to a list of file paths.

Once all the files and names have been found the merge_files(file_paths, names_path, target_path) method is called in the code pointed to by the code parameter.

### Example

python walking_multi_merger.py --source=test-data --code=merge_files.py --regex=htseq_count.txt --target_path=test-data/merged.tsv --verbose

# merge_files.py 
Implements merge_files(file_paths, names_path, target_path)

The list of file names is read from the file pointed to by names_path. These are assumed to be the names of the files in file_path so must match in length

The list of names is shortened by removing and start or end text common to all names

All files in file_path are then read looking for lines with exactly one tab.

These lines are then split into two to polulate a dictionary of dictionaies. Where the first key is part before the tab and the second key is the name.

This dictionary is then writen out as a tab seperated file such that the coumn names are the unique parts of the names and the row names are the first part of each line.

## Directly callable
This tool is directly callable but this was many implemented for the galaxy tool.

###
python merge_files.py --file_path=test-data/C03/htseq_count.txt --file_path=test-data/C01/htseq_count.txt --file_path=test-data/C02/htseq_count.txt --file_path=test-data/C05/htseq_count.txt --names_path=test-data/names.txt --target_path=test-data/merged.tsv 

## Galaxy
Galaxy version of this tool is a TODO!
