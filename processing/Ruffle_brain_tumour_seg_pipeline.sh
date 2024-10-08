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

# nnUnet_predict -i $input_path -o $output_path -t Task871_BrainTumourT2PedsPreTrainedEncoderFrozen -m 3d_fullres --save_npz

source_dir="/Users/knilla/Documents/BrainSegmentation/PedsBrainAutoSeg/input"
dest_dir="/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data/CP_pnts"

# Check if source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' does not exist!"
    exit 1
fi

# Create destination directory if it does not exist
if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir"
fi

# Copy files with format 'CP_pnt_XX_YYYY.nii.gz' to respective subfolders
for file in "$source_dir"/CP_pnt_*.nii.gz; do
    # Check if there are files that match the pattern
    if [ ! -e "$file" ]; then
        echo "No matching files found in the source directory."
        exit 1
    fi
    
    # Extract the prefix 'CP_pnt_XX'
    filename=$(basename -- "$file")
    prefix=$(echo "$filename" | cut -d'_' -f 1,2,3)
    
    # Create the directory based on the prefix if it doesn't exist
    target_dir="$dest_dir/$prefix"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # Copy the file to the appropriate folder
    cp "$file" "$target_dir/"
    
    echo "Copied '$filename' to '$target_dir/'"
done

cd /Users/knilla/Documents/BrainSegmentation/nnUNet_mod
source venv/bin/activate

output_base_dir_allseq="/Users/knilla/Documents/BrainSegmentation/nnUnet_mod/results/CP_pnts_allseq"
output_base_dir_allseq_abnormality="/Users/knilla/Documents/BrainSegmentation/nnUnet_mod/results/CP_pnts_allseq_abnormality"

# Check if destination directory exists
if [ ! -d "$dest_dir" ]; then
    echo "Error: Destination directory '$dest_dir' does not exist!"
    exit 1
fi

# Create output directory if it does not exist
if [ ! -d "$output_base_dir" ]; then
    mkdir -p "$output_base_dir"
fi

# Loop through all subfolders in the destination directory
date
for input_path in "$dest_dir"/*/; do
    # Extract the subfolder name (e.g., 'CP_pnt_01')
    subfolder=$(basename "$input_path")
    echo $subfolder

    # Define the corresponding output directory for this subfolder
    output_path_pnt_allseq="$output_base_dir_allseq/$subfolder"
    output_path_pnt_allseq_abnormality="$output_base_dir_allseq_abnormality/$subfolder"
    
    # Create the output directory for this subfolder if it doesn't exist
    if [ ! -d "$output_path_pnt_allseq" ]; then
        mkdir -p "$output_path_pnt_allseq"
    fi
    if [ ! -d "$output_path_pnt_allseq_abnormality" ]; then
        mkdir -p "$output_path_pnt_allseq_abnormality"
    fi

    # Run the nnUNet_predict command
    nnUNet_predict -i "$input_path" -o "$output_path_pnt_allseq" -t Task918_BrainTumour2021_allseq_bratsonly -f all
    nnUNet_predict -i "$input_path" -o "$output_path_pnt_allseq_abnormality" -t Task918_BrainTumour2021_allseq_bratsonly_abnormality -f all

    echo "Processed '$input_path', output saved to '$output_path_pnt'"
done
date
