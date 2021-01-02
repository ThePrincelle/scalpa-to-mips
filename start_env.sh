#!/bin/bash
# start_env.sh
# Creates the environment to run the project in.
# ------------------------------------------------

FILE=$( realpath ${BASH_SOURCE[0]} )
DIR=$(dirname -- "$FILE" )

echo "Downloading project environnement... please wait..."
echo ""

docker pull theprincemax/compil-tester

echo ""
echo "Starting project environnement... please wait..."
echo ""

docker run --rm -it -v "${DIR}/:/app" theprincemax/compil-tester bash