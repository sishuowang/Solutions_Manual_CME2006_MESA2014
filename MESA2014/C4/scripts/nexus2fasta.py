#! /usr/bin/env python

##########################################
from Bio import SeqIO
import sys

##########################################
records = SeqIO.parse(sys.argv[1], "nexus")
count = SeqIO.write(records, sys.argv[2], "fasta")
print("Converted %i records" % count)

