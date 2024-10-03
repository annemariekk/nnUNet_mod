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

output_base_dir="/Users/knilla/Documents/BrainSegmentation/nnUnet_mod/results/CP_pnts"

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
for input_path in "$dest_dir"/*/; do
    # Extract the subfolder name (e.g., 'CP_pnt_01')
    subfolder=$(basename "$input_path")
    echo $subfolder

    # Define the corresponding output directory for this subfolder
    output_path_pnt="$output_base_dir/$subfolder"
    
    # Create the output directory for this subfolder if it doesn't exist
    if [ ! -d "$output_path_pnt" ]; then
        mkdir -p "$output_path_pnt"
    fi

    # Run the nnUNet_predict command
    nnUNet_predict -i "$input_path" -o "$output_path_pnt" -t Task918_BrainTumour2021_allseq_bratsonly -f all

    echo "Processed '$input_path', output saved to '$output_path_pnt'"
done

