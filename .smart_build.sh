#!/bin/bash

NPROC=$(cat /proc/cpuinfo | grep -c processor)
NPROC=$(($NPROC == 1 ? 1 : $NPROC - 1))

for arg in "$@"; do
    case $arg in 
        --debug)
            IS_DEBUG="1"
            shift
            ;;
        --release)
            IS_RELEASE="1"
            shift
            ;;
        --relwithdebinfo)
            IS_RELWITHDEBINFO="1"
            shift 
            ;;
    esac
done

# set debug type if not specified
[[ "$IS_DEBUG" == "" ]] && [[ "$IS_RELEASE" == "" ]] && [[ "$IS_RELWITHDEBINFO" == "" ]] && IS_DEFAULT="1"

_warn() {
    echo -e "\033[1;31m$@\033[0m"
}

_test_cmake_dir() {
    [[ -f "$1/CMakeCache.txt" ]] && return 0 
    return 2
}

_cmake() {
    set -x
    cmake "$@"
    set +x
}

_build_cmake_dir() {
    if [[ -z "$IS_DEFAULT" ]]; then
        _warn "CMake build type is defined when generating. Build config may not work."
    fi

    candidates=()

    if [[ "0" != "$(ls | grep cmake-build- | wc -l)" ]]; then
        for candidate in cmake-build-*; do 
            candidates+=("$candidate")
        done
    fi

    [[ -d "build" ]] && candidates+=("build")
    # _warn "$candidates"

    N_CANDIDATES="${#candidates[@]}"
    # _warn $N_CANDIDATES
    if [[ "0" == "$N_CANDIDATES" ]]; then
        return 2
    elif [[ "1" == "$N_CANDIDATES" ]]; then 
        _cmake --build "${candidates[0]}" -j "$NPROC"
        return 0
    fi 

    echo "It seems that you have many possible cmake directories. Select one:"
    for idx in "${!candidates[@]}"; do 
        candidate="${candidates[$idx]}"
        echo -e "\t[$idx] $candidate"
    done
        
    echo -e "\t[$N_CANDIDATES] ALL (default)"
    read -r idx
    [[ -z "$idx" ]] && idx="$N_CANDIDATES"

    if (( $idx >= 0 )) && (( $idx < $N_CANDIDATES )); then
        _cmake --build "${candidates[$idx]}" -j "$NPROC"
    elif [[ "$idx" == "$N_CANDIDATES" ]]; then 
        for candidate in "${candidates[@]}"; do 
            _cmake --build "$candidate" -j "$NPROC"
        done 
    fi
}

_build_internal() {
    if [[ -f "Cargo.toml" ]]; then
        if [[ ! -z "$IS_DEBUG" ]] || [[ ! -z "$IS_DEFAULT" ]]; then
            cargo build 
        elif [[ ! -z "$IS_RELEASE" ]]; then 
            cargo build --release 
        elif [[ ! -z "$IS_RELWITHDEBINFO" ]]; then 
            _warn "[Error Build Type]: cargo has no release with debug info cli!"
            return 22
        fi
    elif [[ -f "build.ninja" ]]; then
        if [[ ! -z "$IS_DEFAULT" ]]; then
            ninja
        else
            _warn "[Error Build Type]: ninja only has default build!"
            return 22
        fi
    elif [[ -f "Makefile" ]]; then
        if [[ ! -z "$IS_DEFAULT" ]]; then
            make "-j$NPROC"
        else
            _warn "[Error Build Type]: make only has default build!"
            return 22
        fi
    else
        if ! _build_cmake_dir; then
            _warn "[No Build File]: cannot find any valid build file!"
            return 2
        fi 
    fi 
    return 0
}

_build_internal
