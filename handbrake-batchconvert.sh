#!/bin/sh

###############################################################################
#
# Script to recursively search a directory and batch convert all files of a given
# file type into another file type via HandBrake conversion.
#
# To run in your environment set the variables:
#   hbcli - Path to your HandBrakeCLI
#
#   dirs - Array of starting directories for recursive search
#
#   input_file_type - Input file type to search for
#
#   output_file_type  - Output file type to convert into
#
###############################################################################

hbcli=/Applications/HandBrakeCLI/HandBrakeCLI
input_file_type="avi"
output_file_type="m4v"

dirs=( '/dir1'
       '/dir2' )


###############################################################################

echo "# Using HandBrakeCLI at $hbcli"
echo "# Converting $input_file_type to $output_file_type"

# Convert from one file to another
convert() {
	# The beginning part, echo "" | , is really important.  Without that, HandBrake exits the while loop.
	echo ""# | $hbcli -i "$1" -o "$2" --preset="Universal";
}

# Iterate over the array of directories
for i in "${dirs[@]}"
do
  echo "Processing source directory: " $i

  # Find the files and pipe the results into the read command because the read command properly handles spaces in directories and files names.
  find "$i" -name *.$input_file_type | while read in_file
  do
        echo "Processing file..."
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
done

echo "DONE CONVERTING FILES"
echo -en "\007"
echo -en "\007"
echo -en "\007"
