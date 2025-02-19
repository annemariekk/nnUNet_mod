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
inpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data/CP_new/'
outpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/results/CP_new/'
mkdir -p "$outpath"
subs='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/processing/subs.txt'

cd /Users/knilla/Documents/BrainSegmentation/nnUNet_mod
source venv/bin/activate

# Loop through each mode and each sequence
for seq in "${sequences[@]}"; do
    for mode in "${modes[@]}"; do
        echo "Running script with mode: $mode and sequences: $seq"

        # Measure and display the elapsed time of each Python call
        start_time=$(date +%s)  # Start time in seconds

        # Run the Python script with the specified arguments
        python processing/autosegment.py --inpath "$inpath" \
                                         --outpath "$outpath" \
                                         --subs "$subs" \
                                         --mode "$mode" \
                                         --sequences "$seq" \
                                         --nocleanup

        end_time=$(date +%s)  # End time in seconds
        elapsed_time=$((end_time - start_time))

        echo "Elapsed time for mode: $mode, sequence: $seq is ${elapsed_time} seconds"
    done
done

# Run nnUnet with weights from Boyd et. al.
start_time=$(date +%s)  # Start time in seconds

# Run the Python script with the specified arguments
python processing/autosegment.py --inpath "$inpath" \
                                 --outpath "$outpath" \
                                 --subs "$subs" \
                                 --mode "boyd" \
                                 --sequences "['T2']" \
                                 --nocleanup

end_time=$(date +%s)  # End time in seconds
elapsed_time=$((end_time - start_time))

echo "Elapsed time for mode: $mode, sequence: $seq is ${elapsed_time} seconds"
