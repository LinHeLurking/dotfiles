#!/bin/bash

_smart_build_wrapper() {
    local _NPROC=$(cat /proc/cpuinfo | grep -c processor)
    _NPROC=$(($_NPROC == 1 ? 1 : $_NPROC - 1))

    local _IS_DEBUG=""
    local _IS_RELEASE=""
    local _IS_DEFAULT=""
    local _IS_RELWITHDEBINFO=""

    _warn() {
        echo -e "\033[1;31m$@\033[0m"
    }

    _cmd() {
        echo -e "\033[1;32m$@\033[0m"
        eval "$@"
    }

    _test_cmake_dir() {
        [[ -f "$1/CMakeCache.txt" ]] && return 0 
        return 2
    }

    _build_cmake_dir() {
        if [[ -z "$_IS_DEFAULT" ]]; then
            _warn "CMake build type is defined when generating. Build config may not work."
        fi

        local candidates=()

        if [[ "0" != "$(ls | grep cmake-build- | wc -l)" ]]; then
            for candidate in cmake-build-*; do 
                if _test_cmake_dir $candidate; then
                    candidates+=("$candidate")
                fi
            done
        fi

        [[ -d "build" ]] && _test_cmake_dir "build" && candidates+=("build")
        # _warn "$candidates"

        local _N_CANDIDATES="${#candidates[@]}"
        # _warn $_N_CANDIDATES
        if [[ "0" == "$_N_CANDIDATES" ]]; then
            return 2
        elif [[ "1" == "$_N_CANDIDATES" ]]; then 
            _cmd cmake --build "${candidates[1]}" -j "$_NPROC"
            return 0
        fi 

        echo "It seems that you have many possible cmake directories. Select one:"
        for idx in "${!candidates[@]}"; do 
            candidate="${candidates[$idx]}"
            echo -e "\t[$idx] $candidate"
        done
            
        echo -e "\t[$_N_CANDIDATES] ALL (default)"
        read -r idx
        [[ -z "$idx" ]] && idx="$_N_CANDIDATES"

        if (( $idx >= 0 )) && (( $idx < $_N_CANDIDATES )); then
            _cmd cmake --build "${candidates[$idx]}" -j "$_NPROC"
        elif [[ "$idx" == "$_N_CANDIDATES" ]]; then 
            for candidate in "${candidates[@]}"; do 
                _cmd cmake --build "$candidate" -j "$_NPROC"
            done 
        fi
    }


    for arg in "$@"; do
        case $arg in 
            --debug)
                _IS_DEBUG="1"
                shift
                ;;
            --release)
                _IS_RELEASE="1"
                shift
                ;;
            --relwithdebinfo)
                _IS_RELWITHDEBINFO="1"
                shift 
                ;;
        esac
    done

    # set debug type if not specified
    [[ "$_IS_DEBUG" == "" ]] && [[ "$_IS_RELEASE" == "" ]] && [[ "$_IS_RELWITHDEBINFO" == "" ]] && _IS_DEFAULT="1"

    if [[ -f "Cargo.toml" ]]; then
        if [[ ! -z "$_IS_DEBUG" ]] || [[ ! -z "$_IS_DEFAULT" ]]; then
            _cmd cargo build 
        elif [[ ! -z "$_IS_RELEASE" ]]; then 
            _cmd cargo build --release 
        elif [[ ! -z "$_IS_RELWITHDEBINFO" ]]; then 
            _warn "[Error Build Type]: cargo has no release with debug info cli!"
            return 22
        fi
    elif [[ -f "build.ninja" ]]; then
        if [[ ! -z "$_IS_DEFAULT" ]]; then
            _cmd ninja
        else
            _warn "[Error Build Type]: ninja only has default build!"
            return 22
        fi
    elif [[ -f "Makefile" ]]; then
        if [[ ! -z "$_IS_DEFAULT" ]]; then
            _cmd make "-j$_NPROC"
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
alias build="_smart_build_wrapper"
