#!/bin/bash
set -eu

function test_command {
    cmd=${*:1}
    set +e
    if ! $cmd &> /dev/null; then
        echo "error: command $cmd not found"
        exit 1
    fi
    set -e
}

function dependencies_check {
    test_command file --help
    test_command find --help
    test_command rm --help
    test_command sed --help
}

function scan {
    local path=$1
    local result_path
    local result
    result_path=$(mktemp)
    echo 0 > "$result_path"
    find "$path" -type f | while read -r file; do
	local file_mime
	echo -n "checking ${file}... "
	file_mime="$(file -b --mime-encoding "$file")"
	if [[ "$file_mime" = "binary" ]]; then
	    echo "skipped (binary)"
	    continue
	fi
	if ! search_sk "$file"; then
	    echo "ko (potential Secret Key found)"
	    echo 1 > "$result_path"
	    continue
	fi
	if ! search_ak "$file"; then
	    echo "ko (potential Access Key found)"
	    echo 1 > "$result_path"
	    continue
	fi
	echo "ok"
    done
    result=$(cat "$result_path")
    rm "$result_path"
    return "$result"
}

function search_ak {
    local file=$1
    local matched
    local digits
    local alphas
    matched=$(sed -nE 's/(^|.*[^a-zA-Z0-9]+)([A-Z0-9]{20})([^a-zA-Z0-9]+.*|$)/\2/p' "$file")
    if [[ -z "$matched" ]]; then
	return 0
    fi
    for ak in $matched; do
	digits=$(echo -n "$ak" | tr -d "\[^0-9\]" | wc -c)
	alphas=$(echo -n "$ak" | tr -d "\[^A-Z\]" | wc -c)
	if (( digits < 3 )) || (( alphas < 3 )); then
	    continue
	fi
	if ! is_ignored_ak "$ak"; then
	    continue
	fi
	return 1
    done
    return 0
}

function is_ignored_ak {
    local ak=$1
    local ignored_aks
    ignored_aks=(0123456789ABCDEFGHIJ ABCDEFGHIJ0123456789)
    for ignored in "${ignored_aks[@]}"; do
	if [[ "$ak" = "$ignored" ]]; then
	    return 1
	fi
    done
    return 0
}

function search_sk {
    local file=$1
    local matched
    local digits
    local alphas
    matched=$(sed -nE 's/(^|.*[^a-zA-Z0-9]+)([A-Z0-9]{40})([^a-zA-Z0-9]+.*|$)/\2/p' "$file")
    if [[ -z "$matched" ]]; then
	return 0
    fi
    for sk in $matched; do
	digits=$(echo -n "$sk" | tr -d "\[^0-9\]" | wc -c)
	alphas=$(echo -n "$sk" | tr -d "\[^A-Z\]" | wc -c)
	if (( digits < 5 )) || (( alphas < 5 )); then
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
    echo "- Access Keys (20 capital alphanumeric string)"
    echo "- Secret Keys (40 capital alphanumeric string)"
}

if [ "$#" -ne 1 ]; then
    print_help
    exit 1
fi

dependencies_check

path=$1
if ! scan "$path" ; then
    echo "!!! Potential leak found !!!"
    exit 1
fi
echo "All good, bye"
