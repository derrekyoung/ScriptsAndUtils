#!/bin/sh

###############################################################################
#
# Script to recursively search a directory and batch convert all files of a given
# file type into another file type via HandBrake conversion.
#
# To run in your environment set the variables:
#   hbcli - Path to your HandBrakeCLI
#	
#   source_dir - Starting directory for recursive search
#	
#   input_file_type - Input file type to search for
#	
#   output_file_type  - Output file type to convert into
#
#
# Change log:
# 2012-01-08: Initial release.  Tested on Mac OS X Lion.
#
###############################################################################

hbcli=/Applications/HandBrakeCLI/HandBrakeCLI
source_dir="/Movies"
input_file_type="avi"
output_file_type="m4v"

echo "# Using HandBrakeCLI at "$hbcli
echo "# Using source directory "$source_dir
echo "# Converting "$input_file_type" to "$output_file_type

# Convert from one file to another
convert() {
	# The beginning part, echo "" | , is really important.  Without that, HandBrake exits the while loop.
	echo "" | $hbcli -i "$1" -o "$2" --preset="Universal";
}

# Find the files and pipe the results into the read command.  The read command properly handles spaces in directories and files names.
find "$source_dir" -name *.$input_file_type | while read in_file
do
        echo "Processing…"
	echo ">Input  "$in_file

	# Replace the file type
	out_file=$(echo $in_file|sed "s/\(.*\.\)$input_file_type/\1$output_file_type/g")
	echo ">Output "$out_file

	# Convert the file
	convert "$in_file" "$out_file"

	if [ $? != 0 ]
        then
            echo "$in_file had problems" >> handbrake-errors.log  
        fi

	echo ">Finished "$out_file "\n\n"
done

echo "DONE CONVERTING FILES"