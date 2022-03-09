#!/bin/bash
ROOT=$(cd "$(dirname $0)/.." && pwd)
exit_code=0

echo -n "testing non leaked data... "
if $ROOT/scan.sh $ROOT/tests/good &> /dev/null; then
    echo "ok"
else
    echo "fail!"
    exit_code=1
fi

echo -n "testing with leaked ak... "
if ! $ROOT/scan.sh $ROOT/tests/bad-ak &> /dev/null; then
    echo "ok"
else
    echo "fail!"
    exit_code=1
fi

echo -n "testing with leaked sk... "
if ! $ROOT/scan.sh $ROOT/tests/bad-sk &> /dev/null; then
    echo "ok"
else
    echo "fail!"
    exit_code=1
fi

echo -n "testing with shellcheck... "
if shellcheck $ROOT/scan.sh &> /dev/null; then
    echo "ok"
else
    echo "fail!"
    exit_code=1
fi

exit $exit_code
