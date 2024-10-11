PARENTDIR='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data'
cd $PARENTDIR

# Reformat and move NIFTI files
DIRECTORY='/Users/knilla/Documents/Data/Patients/BrainSegmentation/CP/NIFTI'

# Create the NEW directory if it doesn't exist
NEW_DIR="./CP_pnt_TYPE"
mkdir -p "$NEW_DIR"

# Loop through the subdirectories with the format CP_pnt_XX
for SUBDIR in "$DIRECTORY"/CP_pnt_*; do
    if [ -d "$SUBDIR" ]; then
        # Extract the number XX from the subdirectory name
        BASENAME=$(basename "$SUBDIR")
        NUMBER=$(echo "$BASENAME" | sed 's/[^0-9]*//g')

        # Define the source and destination file paths
        FLAIR_SRC="$SUBDIR/outputDir/FL_to_SRI_brain.nii.gz"
        T1_SRC="$SUBDIR/outputDir/T1_to_SRI_brain.nii.gz"
        T1CE_SRC="$SUBDIR/outputDir/T1CE_to_SRI_brain.nii.gz"
        T2_SRC="$SUBDIR/outputDir/T2_to_SRI_brain.nii.gz"

        target_dir="$NEW_DIR/CP_pnt_${NUMBER}"
        mkdir -p "$target_dir"

        FLAIR_DST="$target_dir/FLAIR.nii.gz"
        T1_DST="$target_dir/T1.nii.gz"
        T1CE_DST="$target_dir/T1CE.nii.gz"
        T2_DST="$target_dir/T2.nii.gz"

        # Initialize a flag and a variable to track copied files
        files_copied=false
        copied_files_list=""

        # Copy and rename the files if they exist at the source and don't already exist at the destination
        if [ -f "$FLAIR_SRC" ] && [ ! -f "$FLAIR_DST" ]; then
            cp "$FLAIR_SRC" "$FLAIR_DST"
            files_copied=true
            copied_files_list+="FLAIR.nii.gz "
        fi

        if [ -f "$T1_SRC" ] && [ ! -f "$T1_DST" ]; then
            cp "$T1_SRC" "$T1_DST"
            files_copied=true
            copied_files_list+="T1.nii.gz "
        fi

        if [ -f "$T1CE_SRC" ] && [ ! -f "$T1CE_DST" ]; then
            cp "$T1CE_SRC" "$T1CE_DST"
            files_copied=true
            copied_files_list+="T1CE.nii.gz "
        fi

        if [ -f "$T2_SRC" ] && [ ! -f "$T2_DST" ]; then
            cp "$T2_SRC" "$T2_DST"
            files_copied=true
            copied_files_list+="T2.nii.gz "
        fi

        # Only print the message if any file was copied, and list the copied files
        if [ "$files_copied" = true ]; then
            echo "$SUBDIR --> $target_dir (Copied files: $copied_files_list)"
        fi
    fi
done
