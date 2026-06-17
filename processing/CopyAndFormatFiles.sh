PARENTDIR='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data'
cd $PARENTDIR

# Reformat and move NIFTI files
DIRECTORY='/Users/knilla/Documents/Data/Patients/BrainSegmentation/CP/NIFTI_3D_post'

# Create the NEW directory if it doesn't exist
NEW_DIR="./CP_3D_post"
mkdir -p "$NEW_DIR"

#study_ID_base="CP_pnt"
PATIENT_LIST='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/processing/subs.txt'

## Initialize an array to store patient names
#patients_to_include=()
#
## Read the text file line by line
#while IFS= read -r line; do
#    patients_to_include+=("$line")
#done < "$PATIENT_LIST"

LOG_DATE=$(date +"%Y%m%d")
LOG_TIME=$(date +"%H%M%S")
LOG_FILE="$NEW_DIR/${LOG_DATE}_${LOG_TIME}_copy_log.txt"
{
# Print the current working directory right at the start
    echo "============================================"
    echo "Current Working Directory: $(pwd)"
    echo "Timestamp: ${LOG_DATE}_${LOG_TIME}"
    echo "============================================"
    echo ""

while IFS= read -r pat; do
    pat="${pat//$'\r'/}"
    # Skip empty lines or comments
    [[ -z "$pat" || "$pat" =~ ^# ]] && continue

    pat_dir="$DIRECTORY/$pat"

    if [ ! -d "$pat_dir" ]; then
        echo "Patient directory not found: $pat_dir — skipping"
        continue
    fi

    echo "============================================"
    echo "Processing patient: $pat"
    echo "============================================"

    date_dirs=()
    for d in "$pat_dir"/*; do
        if [ -d "$d" ]; then
            date_dirs+=("$d")
        fi
    done

    old_ifs="$IFS"
    IFS=$'\n'
    sorted_date_dirs=($(sort <<<"${date_dirs[*]}"))
    IFS="$old_ifs"

    # Loop over date directories
    tp_counter=0
    for date_dir in "${sorted_date_dirs[@]}"; do
        [ -d "$date_dir" ] || continue
        date_name=$(basename "$date_dir")

        echo "--------------------------------------------"
        echo "Processing date: $date_name (TP_$tp_counter)"
        echo "--------------------------------------------"

        OUTPUT="$date_dir/outputDir4"

        FLAIR_SRC="$OUTPUT/FLAIR_n4_reg_be.nii.gz"
        T1_SRC="$OUTPUT/T1_n4_reg_be.nii.gz"
        T1CE_SRC="$OUTPUT/T1CE_n4_reg_be.nii.gz"
        T2_SRC="$OUTPUT/T2_n4_reg_be.nii.gz"

        target_dir="$NEW_DIR"/"$pat"_TP_"$tp_counter"
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

        # Log results for this timepoint
        if [ "$files_copied" = true ]; then
            echo "$OUTPUT --> $target_dir (Copied files: $copied_files_list)"
        else
            echo "Notice: No files copied for $date_name (TP_$tp_counter remains empty, skipped, or already contains files)"
        fi

        # CRITICAL: Always increment the counter so empty/incomplete dates hold their place
        ((tp_counter++))
    done
done < "$PATIENT_LIST"
} 2>&1 | tee "$LOG_FILE"

echo "============================================"
echo "Execution finished. Full log saved to: $LOG_FILE"
echo "============================================"
