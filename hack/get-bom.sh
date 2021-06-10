#!/bin/sh

bomimage="$1"
output="$2"

echo "$bomimage"
echo "$output"

imgpkg pull -i "$bomimage" -o "$output"

for file in "$output"/*
do
    if [[ -f $file ]]; then
	echo "$file"
        mv $file "$output"/base-bom.yaml
    fi
done
