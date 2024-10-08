PARENTDIR='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data'
cd $PARENTDIR

# Reformat and move NIFTI files
DIRECTORY='/Users/knilla/Documents/Data/Patients/BrainSegmentation/CP/NIFTI'

# Create the NEW directory if it doesn't exist
NEW_DIR="./CP_pnt_TYPE"
mkdir -p "$NEW_DIR"

# Loop through the subdirectories with the format test_XX
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

        # FLAIR_DST="$NEW_DIR/CP_pnt_${NUMBER}_FL.nii.gz"
        # T1_DST="$NEW_DIR/CP_pnt_${NUMBER}_T1.nii.gz"
        # T1CE_DST="$NEW_DIR/CP_pnt_${NUMBER}_T1CE.nii.gz"
        # T2_DST="$NEW_DIR/CP_pnt_${NUMBER}_T2.nii.gz"

        echo "$SUBDIR --> $target_dir"

        # Copy and rename the files if they exist
        [ -f "$FLAIR_SRC" ] && cp "$FLAIR_SRC" "$FLAIR_DST"
        [ -f "$T1_SRC" ] && cp "$T1_SRC" "$T1_DST"
        [ -f "$T1CE_SRC" ] && cp "$T1CE_SRC" "$T1CE_DST"
        [ -f "$T2_SRC" ] && cp "$T2_SRC" "$T2_DST"
    fi
done
