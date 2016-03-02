"""
Source: https://raw.githubusercontent.com/mmendez12/sync_paired_end_reads/master/sync_paired_end_reads/syncpairs.py

Editted by Christian Brenninkmeijer University of Manchester to add support for gzip input files
Main code moved to do_sync_pairs(...)
Tried first as is assuming both inputs are unzipped
If it fails retires unzipping first
"""
__author__ = 'mickael'
__author__ = 'mickael'

from Bio import SeqIO
from itertools import izip
import argparse

# Imports added by Christian
import gzip
import os
import shutil
import tempfile


def adjust_name(reads1, reads2):
    for r1, r2 in izip(reads1, reads2):
        r2.name = r1.description
        r2.description = r1.description
        r2.id = r1.description
        yield r2


def remove_space_from_sequence_header(read):
    """ replaces spaces in a read's name by three underscores.
    Args:
        read: A SeqRecord object (see Biopython)

    >>> from Bio.Seq import Seq
    >>> from Bio.SeqRecord import SeqRecord
    >>> from Bio.Alphabet import SingleLetterAlphabet

    >>> read = SeqRecord(Seq("AAAAA",SingleLetterAlphabet),\
                       id="read A", name="read A", description="read A")

    >>> print remove_space_from_sequence_header(read).name
    read___A
    """

    read.description = read.description.replace(' ', '___')
    read.name = read.description
    read.id = read.description
    return read


def next_matching_read(reads1, reads2):
    """ return next read2 that matches read2
    Args:
        reads1: A generator that contains a SeqRecord (see Biopython)

        reads2: A generator that contains a SeqRecord (see Biopython)


    >>> from Bio.Seq import Seq
    >>> from Bio.SeqRecord import SeqRecord
    >>> from Bio.Alphabet import SingleLetterAlphabet

    >>> reads1 = []
    >>> reads2 = []

    >>> reads1.append(SeqRecord(Seq("AAAAA",SingleLetterAlphabet),\
                       id="read A", name="read A", description="read A"))
    >>> reads2.append(SeqRecord(Seq("TTTTT",SingleLetterAlphabet),\
                       id="read A", name="read A", description="read A"))

    >>> reads1.append(SeqRecord(Seq("AAAAA",SingleLetterAlphabet),\
                       id="read B", name="read B", description="read B"))

    >>> reads1.append(SeqRecord(Seq("AAAAA",SingleLetterAlphabet),\
                       id="read C", name="read C", description="read C"))
    >>> reads2.append(SeqRecord(Seq("TTTTT",SingleLetterAlphabet),\
                       id="read C", name="read C", description="read C"))

    >>> match = [read2 for read2 in next_matching_read(reads1, reads2)]
    >>> print match[0].name
    read A
    >>> print match[1].name
    read C
    """

    for read1 in reads1:
        for read2 in reads2:
            if read1.name == read2.name:
                yield read2
                break


# Method added by Christian
def unzip_if_required(file_name):
    print "checking if", file_name,"requires unzipping"

    #Galaxy does not use .gz files and gzip fails without that prefix
    #Even a symlink appears to fail here 
    openfile, gzname = tempfile.mkstemp(suffix='gz')
    print gzname
    with open(gzname, "wb") as tmp:
        shutil.copyfileobj(open(file_name), tmp)

    openfile, tmpfile = tempfile.mkstemp()
    try:
        with open(tmpfile, "wb") as tmp:
            shutil.copyfileobj(gzip.open(gzname), tmp)
    except IOError as e:
        print e
        print "Unzipping not required so using original file"
        os.remove(tmpfile)
        os.remove(gzname)
        return file_name
    print "Unzipped to ", tmpfile
    os.remove(gzname)
    return tmpfile

def do_sync_pairs(reads1, reads2, reads1_output, reads2_output):
    #we'll need to go through the reads1 multiple time and it can be a large file
    #so it's better to use inline func that return a generator
    _reads1 = lambda: (rec for rec in SeqIO.parse(reads1, 'fastq'))
    _reads2 = (rec for rec in SeqIO.parse(reads2, 'fastq'))

    matching_reads2 = (read2 for read2 in next_matching_read(_reads1(), _reads2))
    synced_reads2_names = (read2 for read2 in adjust_name(_reads1(), matching_reads2))

    final_reads1 = (remove_space_from_sequence_header(r1) for r1 in _reads1())
    final_reads2 = (remove_space_from_sequence_header(r2) for r2 in synced_reads2_names)

    SeqIO.write(final_reads1, reads1_output, "fastq")
    SeqIO.write(final_reads2, reads2_output, "fastq")


def main():

    parser = argparse.ArgumentParser()

    parser.add_argument("reads1",help='modified reads')
    parser.add_argument("reads2", help='reads to adjust')

    parser.add_argument('reads1_output',  help='output folder and filename. Note that the folder should already exist')
    parser.add_argument('reads2_output',  help='output folder and filename. Note that the folder should already exist')

    args = parser.parse_args()

    print "Running sync_pairs"
    try:
        #Try without unzipping first
        do_sync_pairs(args.reads1, args.reads2, args.reads1_output, args.reads2_output)
        print "success"
        return
    except Exception as e:
        print "Running without unzipping caused", e

    try:
        reads1_file = unzip_if_required(args.reads1)
        reads2_file = unzip_if_required(args.reads2)

        do_sync_pairs(reads1_file, reads2_file, args.reads1_output, args.reads2_output)

        if args.reads1 != reads1_file:
            print "Deleting",reads1_file
            os.remove(reads1_file)
        if args.reads2 != reads2_file:
            print "Deleting",reads2_file
            os.remove(reads2_file)
    except Exception as e:
        print "failed with",e


if __name__ == '__main__':
    main()
