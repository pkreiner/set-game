#!/bin/bash

# Note: must be run from the directory in which it lives.

# This script starts from a pdf I have,
# '~/elm/set/images/pdf/set-2x2.pdf', and generates a folder full of
# named png files, each with one set card.

./convert-pdf-to-pngs.sh
./split-images.sh
./reindex-cards.sh
python finally-rename-cards.py
