#!/bin/bash
# test.sh
# Testing scalpa to mips compiler
# ----------------------------------------------------------------

FILE=$( realpath ${BASH_SOURCE[0]} )
DIR=$(dirname -- "$FILE" )

# Go to root of project
cd ${DIR}

# Build the compiler
echo "Building compiler..."
make testing

# Run tests
echo ""
echo "Running tests..."
echo ""
for f in "$DIR"/tests/*.pas
do
    # Get Relative path
    testfile=".${f#"$DIR"}"

    echo "Running test for: ${testfile}..."

    # Run test
    if ./a.out "${testfile}" ; then
        echo "Test succeeded for: ${testfile}"
    else
        echo "Test failed on: ${testfile}"
        exit 1
    fi

    echo ""
done

# All tests have passed.
echo "All tests passed successfully."