#!/bin/bash

# variables

Blocked_Extentions=("exe" "bat" "vbs" "scr" "ps1")
Blocked_Words=("virus" "trojan" "malware" "worm" "ransomware")
whitelist_file="whitelist.txt"

# Funtion  to check the file is  Malicious or not

Check_malicious(){
	local filename="$1"
	local Current_File_Extention="${filename##*.}"
	for exe in "${Blocked_Extentions[@]}";
	do
		if [ "$exe" = "$Current_File_Extention" ];
		then 
			return 0
		fi 
	done
	for word in "${Blocked_Words[@]}";
	do
		if grep -qi "$word" "$filename";
		then
			return 0
		fi
	done
	return 1
}

# Funtion  to check the file in whitelist or not

is_in_whitelist() {

    local file="$1"
    local dir="$2"
    local whitelist_full_path="$dir/$whitelist_file"

    if [ ! -f "$whitelist_full_path" ]; then
        return 1
    fi

    if grep -qxF "$file" "$whitelist_full_path";
    then
        return 0
    fi

    return 1
}

# Funtion  to scan Directory

Scan_Directory() {
    local dir_name="$1"
    local malicious_dir="$2"

    shopt -s nullglob

    for file in "$dir_name"/*;
    do
		if is_in_whitelist "$file" "$dir_name" || [ "$(basename "$file")" = "$whitelist_file" ];
		then
			continue
        elif Check_malicious "$file";
        then
            echo "$(date) $file is malicious and it is DELETED" >> "cron.log"
            cp "$file" "$malicious_dir/"
            rm -f "$file"
        fi
    done
}

# Run the checks

sleep 23

dir="$1"
malicious_dir="$2"

if [ ! -f "directory-info.last" ];
then
    Scan_Directory "$dir" "$malicious_dir"
    ls -l "$dir" > directory-info.last
else
    ls -l "$dir" > directory-info.new

    if cmp -s directory-info.last directory-info.new;
    then
        exit 0
    else
        Scan_Directory "$dir" "$malicious_dir"
        cp directory-info.new directory-info.last
    fi
fi