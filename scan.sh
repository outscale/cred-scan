#!/bin/bash
set -eu

function scan {
    local path=$1
    local result=0
    local file_mime
    local old_ifs
    old_ifs="$IFS"
    IFS=$'\n'
    for file in $(find "$path" -type f | xargs --null); do
	echo -n "checking ${file}... "
	file_mime="$(file -b --mime-encoding "$file")"
	if [[ "$file_mime" = "binary" ]]; then
	    echo "skipped (binary)"
	    continue
	fi
	if ! search_sk "$file"; then
	    echo "ko (potential Secret Key found)"
	    result=1
	    continue
	fi
	if ! search_ak "$file"; then
	    echo "ko (potential Access Key found)"
	    result=1
	    continue
	fi
	echo "ok"
    done
    IFS=$old_ifs
    return $result
}

function search_ak {
    local file=$1
    local matched
    local digit_only
    matched=$(sed -nE 's/(^|.*[^A-Z0-9]+)([A-Z0-9]{20})([^A-Z0-9]+.*|$)/\2/p' "$file")
    if [[ -z "$matched" ]]; then
	return 0
    fi
    for ak in $matched; do
	digit_only=$(echo "$ak" | sed -nE 's/.*([0-9]{20}).*/\1/p')
	if [[ -n "$digit_only" ]]; then
	    continue
	fi
	alpha_only=$(echo "$ak" | sed -nE 's/.*([A-Z]{20}).*/\1/p')
	if [[ -n "$alpha_only" ]]; then
	    continue
	fi
	return 1
    done
    return 0
}

function search_sk {
    local file=$1
    local matched
    local digit_only
    matched=$(sed -nE 's/(^|.*[^A-Z0-9]+)([A-Z0-9]{40})([^A-Z0-9]+.*|$)/\2/p' "$file")
    if [[ -z "$matched" ]]; then
	return 0
    fi
    for sk in $matched; do
	digit_only=$(echo "$sk" | sed -nE 's/.*([0-9]{40}).*/\1/p')
	if [[ -n "$digit_only" ]]; then
	    continue
	fi
	alpha_only=$(echo "$sk" | sed -nE 's/.*([A-Z]{40}).*/\1/p')
	if [[ -n "$alpha_only" ]]; then
	    continue
	fi
	return 1
    done
    return 0
}

function print_help {
    echo "scan credentials in a specific folder"
    echo "$0 FOLDER_PATH"
    echo ""
    echo "Supported credentials:"
    echo "- Access Keys (20 capital hexadecimal string)"
    echo "- Secret Keys (40 capital hexadecimal string)"
}

if [ "$#" -ne 1 ]; then
    print_help
    exit 1
fi
path=$1
if ! scan "$path" ; then
    echo "!!! Potential leak found !!!"
    exit 1
fi
echo "All good, bye"
