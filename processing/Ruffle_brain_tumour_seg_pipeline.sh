#!/bin/bash

modes=("tissue" "abnormality")
sequences=("['FLAIR','T1','T1CE','T2']" \
                      "['FLAIR']" \
                      "['T1']" \
                      "['T1CE']" \
                      "['T2']" \
                      "['FLAIR','T2']" \
                      "['FLAIR','T1CE']" \
                      "['FLAIR','T1CE','T2']")

# Define input and output paths
inpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data/CP_pnt_TYPE/'
outpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/results/CP_pnts/'
subs='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/processing/subs.txt'

cd /Users/knilla/Documents/BrainSegmentation/nnUNet_mod
source venv/bin/activate

# Loop through each mode and each sequence
for seq in "${sequences[@]}"; do
    for mode in "${modes[@]}"; do
        echo "Running script with mode: $mode and sequences: $seq"

        # Run the Python script with the specified arguments
        python processing/autosegment.py --inpath "$inpath" \
                             --outpath "$outpath" \
                             --subs "$subs" \
                             --mode "$mode" \
                             --sequences "$seq" \
                             --nocleanup
    done
done
