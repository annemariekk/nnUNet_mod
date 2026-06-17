#!/bin/bash

#modes=("tissue" "abnormality")
#sequences=("['FLAIR','T1','T1CE','T2']" \
#                      "['FLAIR']" \
#                      "['T1']" \
#                      "['T1CE']" \
#                      "['T2']" \
#                      "['FLAIR','T2']" \
#                      "['FLAIR','T1CE']" \
#                      "['FLAIR','T1CE','T2']")
#sequences=("['T1']" \
#           "['T2']" \
#           "['T1','T2']")

modes=("abnormality")
sequences=("['FLAIR','T1','T1CE','T2']")

# Define input and output paths
inpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/data/CP_3D_post'
outpath='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/results/CP_3D_pre_post'
mkdir -p "$outpath"
subs='/Users/knilla/Documents/BrainSegmentation/nnUNet_mod/processing/subs.txt'

# Create a temporary file path to store the expanded TP list
temp_subs="${subs}.tmp_tp_list"

# --- Dynamic TP Expansion Step ---
echo "Expanding root patient IDs to find all available timepoints..."
> "$temp_subs" # Clear/create the temporary file

while IFS= read -r pat; do
    pat="${pat//$'\r'/}"
    [[ -z "$pat" || "$pat" =~ ^# ]] && continue

    # Search inpath for any directory starting with the patient ID followed by _TP_
    # e.g., if pat is "CP_pnt_01", this finds "CP_pnt_01_TP_1", "CP_pnt_01_TP_2", etc.
    for tp_dir in "$inpath"/"${pat}"_TP_*; do
        if [ -d "$tp_dir" ]; then
            tp_name=$(basename "$tp_dir")
            echo "$tp_name" >> "$temp_subs"
        fi
    done
done < "$subs"

# Quick check to make sure we actually matched some timepoints
if [ ! -s "$temp_subs" ]; then
    echo "Error: No matching _TP_ directories found in $inpath for the listed patients."
    rm -f "$temp_subs"
    exit 1
fi
# ---------------------------------

cd /Users/knilla/Documents/BrainSegmentation/nnUNet_mod
source venv/bin/activate

LOG_DATE=$(date +"%Y%m%d")
LOG_TIME=$(date +"%H%M%S")
LOG_FILE="${outpath}/${LOG_DATE}_${LOG_TIME}_log.txt"
{
# Loop through each mode and each sequence
for seq in "${sequences[@]}"; do
    for mode in "${modes[@]}"; do
        echo "Running script with mode: $mode and sequences: $seq"

        # Measure and display the elapsed time of each Python call
        start_time=$(date +%s)  # Start time in seconds

        # Run the Python script with the specified arguments
        python processing/autosegment.py --inpath "$inpath" \
                                         --outpath "$outpath" \
                                         --subs "$temp_subs" \
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
                                 --subs "$temp_subs" \
                                 --mode "boyd" \
                                 --sequences "['T2']" \
                                 --nocleanup

end_time=$(date +%s)  # End time in seconds
elapsed_time=$((end_time - start_time))

echo "Elapsed time for mode: $mode, sequence: $seq is ${elapsed_time} seconds"
}

# --- CLEANUP ---
echo "Cleaning up temporary files..."
rm -f "$temp_subs"
echo "Done"
