#!/bin/bash

# Variables
whitlist_file="whitelist.txt"

# Function to show options
Show_Options() {
    local file="$1"

    echo "Filename: $file"
    echo ""
    echo "1 - Restore this file back into dir."
    echo "2 - Permanently delete this file from malicious_dir."
    echo "3 - Leave this file as-is and go back to the list."
    echo "Enter your Choice:"

    read -r option
    return "$option"
}

# Function to list files
List_files() {
    local malicious_dir="$1"
    local dir="$2"

    while true;
    do
        # Get the current files in malicious_dir
        files=("$malicious_dir"/*)

        # Check if there are no files
        if [ "$(ls -l "$malicious_dir" | wc -l)" -lt 2 ];
        then
            echo "No malicious files to review."
            exit 0
        fi

        # Show numbered files
        counter=1

        for file in "${files[@]}";
        do
            echo "$counter. $file"
            counter=$((counter + 1))
        done
        echo "0.Exit"

        echo "Enter your choice:"
        read -r filenumber
        if [ $filenumber -eq 0 ];
        then
            exit 0
        fi
        # Convert user's number to array index
        index=$((filenumber - 1))

        # Get selected file
        selected_file="${files[$index]}"

        Show_Options "$selected_file"
        option=$?

        if [ "$option" -eq 1 ];
        then
            local whitelist_full_path="$(realpath -m "$dir/$whitlist_file")"
            cp "$selected_file" "$dir/"
            echo "$dir/$(basename "$selected_file")" >> "$whitelist_full_path"
            rm -f "$selected_file"
            echo "Restored $(basename "$selected_file") to $dir."
            echo""

        elif [ "$option" -eq 2 ];
        then
            rm -f "$selected_file"
            echo "$(basename "$selected_file") permanently deleted."
            echo""

        elif [ "$option" -eq 3 ];
        then
            continue
        fi
    done
}

# Run the checks
if [ $# -lt 2 ];
then
    echo "You must stick to the format."
    echo "restore.sh dir malicious_dir"
    exit 1
fi

dir="$1"
malicious_dir="$2"

List_files "$malicious_dir" "$dir"