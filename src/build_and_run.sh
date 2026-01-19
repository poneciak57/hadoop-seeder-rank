#!/bin/bash
# Generic wrapper to compile and run C++ code on the worker node
# Usage: ./build_and_run.sh source_file.cpp

SRC=$1
BIN="./${SRC%.*}_bin"

# Only compile if binary doesn't exist
if [ ! -f "$BIN" ]; then
    # Compile optimizations should match original script
    g++ -O3 -std=c++11 -o "$BIN" "$SRC"
fi

# Execute the binary, piping stdin/stdout transparently
exec "$BIN"