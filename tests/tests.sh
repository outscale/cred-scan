#!/bin/bash
ROOT=$(cd "$(dirname $0)/.." && pwd)
exit_code=0

for folder in $(find $ROOT/tests/ -type d | xargs); do
    if [[ "folder" = "." ]]; then
	continue
    fi
    bn=$(basename $folder)
    if [[ "$bn" = "tests" ]]; then
	continue
    fi
    expected_result=$(echo $bn | cut -d '-' -f 1)
    echo -n "$bn..."
    $ROOT/scan.sh $folder &> /dev/null
    result=$?
    if [[ "$expected_result" = "bad" ]] && [[ "$result" != "0" ]]; then
	 echo "ok"
    elif [[ "$expected_result" = "good" ]] && [[ "$result" = "0" ]]; then
	echo "ok"
    else
	echo "ko"
	exit_code=1
    fi
done

echo -n "testing with shellcheck... "
if shellcheck $ROOT/scan.sh &> /dev/null; then
    echo "ok"
else
    echo "fail!"
    exit_code=1
fi

if [[ "$exit_code" = "1" ]]; then
    echo "!!! Tests failed !!!"
fi
exit $exit_code
