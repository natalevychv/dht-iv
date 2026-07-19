#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# run.sh - Generic VHDL simulation runner using GHDL
#
# Usage:
#   ./run.sh <target> [wave]
#       Compile and simulate selected target.
#       Optional "wave" opens GTKWave after simulation.
#
#   ./run.sh all
#       Run all available targets without opening GTKWave.
#
#   ./run.sh clean
#       Remove generated work and simulation files.
#
# Source files:
#   sources/common.txt is always compiled.
#   sources/<target>.txt contains target-specific sources.
#
# Requirements:
#   - GHDL with VHDL-2008 support
#   - GTKWave (optional, only for waveform viewing)
# -----------------------------------------------------------------------------

set -e

WORKDIR=work
SIMDIR=sim
SOURCES_DIR=sources
STD=08

GHDL_FLAGS="--std=$STD --workdir=$WORKDIR -fsynopsys"

mkdir -p "$WORKDIR" "$SIMDIR"


# -----------------------------------------------------------------------------
# Available targets
# -----------------------------------------------------------------------------

TARGETS=()

for file in "$SOURCES_DIR"/*.txt; do
    name=$(basename "$file" .txt)

    if [ "$name" != "common" ]; then
        TARGETS+=("$name")
    fi
done


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

analyze_file()
{
    local file=$1

    if [ -z "$file" ]; then
        return
    fi

    if [[ "$file" =~ ^# ]]; then
        return
    fi

    echo "Analyzing: $file"
    ghdl -a $GHDL_FLAGS "$file"
}


compile_sources()
{
    local target=$1

    echo ">>> Analysis (ghdl -a)"

    while IFS= read -r file || [ -n "$file" ]; do
        analyze_file "$file"
    done < "$SOURCES_DIR/common.txt"


    while IFS= read -r file || [ -n "$file" ]; do
        analyze_file "$file"
    done < "$SOURCES_DIR/$target.txt"
}


run_target()
{
    local target=$1
    local open_wave=$2

    TOP="${target}_tb"
    WAVEFILE="$SIMDIR/${target}.ghw"

    if [ ! -f "$SOURCES_DIR/$target.txt" ]; then
        echo "Unknown target: $target"
        exit 1
    fi

    echo ""
    echo "================================="
    echo " Target: $target"
    echo "================================="

    compile_sources "$target"


    echo ">>> Elaboration (ghdl -e)"
    ghdl -e $GHDL_FLAGS "$TOP"


    echo ">>> Simulation (ghdl -r)"
    ghdl -r $GHDL_FLAGS "$TOP" --wave="$WAVEFILE"


    if [ "$open_wave" = "wave" ]; then
        echo ">>> Opening GTKWave"
        gtkwave "$WAVEFILE" &
    fi

    echo ">>> Done. Waveform saved: $WAVEFILE"
}


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

if [ "$1" = "clean" ]; then
    rm -rf "$WORKDIR" "$SIMDIR"
    echo "Clean complete."
    exit 0
fi


if [ -z "$1" ]; then
    echo "Available targets:"
    for t in "${TARGETS[@]}"; do
        echo "  $t"
    done

    echo ""
    echo "Usage:"
    echo "  ./run.sh <target> [wave]"
    echo "  ./run.sh all"
    echo "  ./run.sh clean"

    exit 0
fi


if [ "$1" = "all" ]; then

    for target in "${TARGETS[@]}"; do
        run_target "$target"
    done

    exit 0
fi


run_target "$1" "$2"