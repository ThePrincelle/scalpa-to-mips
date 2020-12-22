#!/bin/bash
# test.sh
# Testing scalpa to mips compiler
# ----------------------------------------------------------------

FILE=$( realpath ${BASH_SOURCE[0]} )
DIR=$(dirname -- "$FILE" )

SCALPA_EXT=".pas"

# Go to root of project
cd ${DIR}

# Build the compiler
echo ""
echo "🛠  Building compiler..."
echo "--------------------"
echo ""
make

# Run tests
echo ""
echo "🔄  Running tests..."
echo "--------------------"
echo ""
for f in "$DIR"/tests/*"${SCALPA_EXT}"
do
    # Get Relative path
    testfile=".${f#"$DIR"}"

    # Run tests on file
    echo "- Running tests for: ${testfile}..."
    echo ""

    # Run compiler on file
    echo "  🔄  Running Scalpa to MIPS compiler on: ${testfile_mips}"
    echo ""

    if ./a.out "${testfile}" ; then
        echo "  ✅  Compilation succeeded for: ${testfile}"
        echo ""

        testfile_mips="${testfile%"$SCALPA_EXT"}.s"

        # Run MIPS compiled code
        echo "  🔄  Running compiled MIPS code: ${testfile_mips}"
        echo -e "\033[32m"

        if java -jar Mars4_5.jar dec v1 "${testfile_mips}" ae1 se1 ; then
            echo -e "\033[0m"
            echo "  ✅  MIPS code runned successfully for: ${testfile_mips}"
        else
            echo -e "\033[0m"
            echo "🔥  Error for running compiled MIPS code on: ${testfile_mips}"
            exit 1
        fi

    else
        echo "🔥  Compilation failed for: ${testfile}"
        exit 1
    fi

    echo ""
    echo "✅  Tests passed for: ${testfile}"
    echo ""
done

# All tests have passed.
echo "--------------------"
echo "✅  All tests passed successfully."