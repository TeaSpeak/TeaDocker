#!/bin/bash

LOG_FILE="logs/build.log"
build_verbose=0
build_release=1
build_debug=0

function print_help() {
    echo "Possible arguments:"
    echo "  --verbose=[yes|no]          | Enable verbose build output (Default: $build_verbose)"
    echo "  --enable-release=[yes|no]   | Enable release build (Default: $build_release)"
    echo "  --enable-debug=[yes|no]     | Enable debug build (Default: $build_debug)"
}

function parse_arguments() {
    # Preprocess the help parameter
    for argument in $@; do
        if [[ "$argument" = "--help" ]] || [[ "$argument" = "-h" ]]; then
            print_help
            exit 1
        fi
    done

    shopt -s nocasematch
    for argument in $@; do
        echo "Argument: $argument"
        if [[ "$argument" =~ ^--verbose(=(y|1)?[[:alnum:]]*$)?$ ]]; then
            build_verbose=$($([[ -z "${BASH_REMATCH[1]}" ]] || [[ ! -z "${BASH_REMATCH[2]}" ]]) && echo "1" || echo "0")

            if [[ ${build_verbose} ]]; then
                echo "Enabled verbose output"
            fi
        elif [[ "$argument" =~ ^--enable-release(=(y|1)?[[:alnum:]]*$)?$ ]]; then
            build_release=$($([[ -z "${BASH_REMATCH[1]}" ]] || [[ ! -z "${BASH_REMATCH[2]}" ]]) && echo "1" || echo "0")

            if [[ ${build_release} ]]; then
                echo "Enabled release build!"
            fi
        elif [[ "$argument" =~ ^--enable-debug(=(y|1)?[[:alnum:]]*$)?$ ]]; then
            build_debug=$($([[ -z "${BASH_REMATCH[1]}" ]] || [[ ! -z "${BASH_REMATCH[2]}" ]]) && echo "1" || echo "0")

            if [[ ${build_debug} ]]; then
                echo "Enabled debug build!"
            fi
        fi
    done
}

function execute() {
    time_begin=$(date +%s%N)

    #Execute the command
    if [[ "$#" -gt 2 ]]; then
        echo "[EXECUTE] Executing commands:" >> ${LOG_FILE}
        for command in "${@:2}"; do
            echo "[EXECUTE]   $command" >> ${LOG_FILE}
        done
    else
        echo "[EXECUTE] Executing command \"$2\"" >> ${LOG_FILE}
    fi

    for command in "${@:2}"; do
        echo "$> $command" >> ${LOG_FILE}
        if [[ ${build_verbose} -gt 0 ]]; then
            echo "$> $command"
        fi

        error=""
        if [[ ${build_verbose} -gt 0 ]]; then
            if [[ -f ${LOG_FILE}.tmp ]]; then
                rm ${LOG_FILE}.tmp
            fi
            eval "${command}" |& tee ${LOG_FILE}.tmp | grep -E '^[^(/\S*/libstdc++.so\S*: no version information available)].*'

            error_code=${PIPESTATUS[0]}
            error=$(cat ${LOG_FILE}.tmp)
            rm ${LOG_FILE}.tmp
        else
            error=$(eval "${command}" 2>&1)
            error_code=$?
            echo "$error" >> ${LOG_FILE}
        fi


        if [[ ${error_code} -ne 0 ]]; then
            break
        fi
    done

    #Log the result
    time_end=$(date +%s%N)
    time_needed=$(($time_end - $time_begin))
    time_needed_ms=$(($time_needed/1000000))
    echo "[EXECUTE] Command exited with exit code $error_code (Runtime ${time_needed_ms}ms)" >> ${LOG_FILE}

    if [[ ${error_code} -ne 0 ]]; then
        handle_failure $1
    fi

    echo "Command execution required ${time_needed_ms}ms"
    error=""
}

function handle_failure() {
    # We cut of the nasty "node: /usr/lib/libstdc++.so.6: no version information available (required by node)" message
    echo "--------------------------- [ERROR] ---------------------------"
    echo "We've encountered an fatal error, which isn't recoverable!"
    echo "                    Aborting build process!"
    echo ""
    echo "Error message: $@"
    if [[ ${build_verbose} -eq 0 ]] && [[ "$error" != "" ]]; then
        echo "Command log: (lookup \"${LOG_FILE}\" for detailed output!)"
        echo "$error" | grep -E '^[^(/\S*/libstdc++.so\S*: no version information available)].*'
    fi
    echo "--------------------------- [ERROR] ---------------------------"
    exit 1
}

BASEDIR=$(dirname "$0")
cd ${BASEDIR}

error=""

LOG_FILE="`pwd`/$LOG_FILE"
if [[ ! -d $(dirname ${LOG_FILE}) ]]; then
    mkdir -p $(dirname ${LOG_FILE})
fi

echo "Script arguments: $@ ($#)"
if [[ "$1" == "bash" ]]; then
    bash
    exit 0
fi

parse_arguments ${@:1}

if [[ -e "$LOG_FILE" ]]; then
    rm "$LOG_FILE"
fi

echo "Initializing shell"
source /etc/profile

echo "Switching to project base directory"
cd /build/TeaWeb &>/dev/null
[[ $? -eq 0 ]] || {
    handle_failure "Failed to enter project directory!"
}
echo "Updating project and submodules"
execute \
    "Failed to update submodules" \
    "git pull" \
    "git submodule update --init --recursive --remote --checkout" \
    "git status &>/dev/null" #We need this to "attach" to git else the git diff dosn't work


function build_native() {
    #Build native modules
    cd asm
    [[ $? -eq 0 ]] || {
        handle_failure "Failed to enter native source directory!"
    }
    echo "Building opus"

    execute \
        "Failed to make opus" \
        "./make_opus.sh"

    if [[ ! -d build ]]; then
        mkdir build
    fi
    cd build
    [[ $? -eq 0 ]] || {
        handle_failure "Failed to enter native build directory!"
    }
    echo "Prepare native stuff"
    execute \
        "Failed to prepare native builds" \
        "emcmake cmake .."

    echo "Build native stuff"
    execute \
        "Failed to build native builds" \
        "emmake make -j 4"

    cd ../../
}

echo "---------- Native modules ---------- "
build_native

echo "----------   Web client    ----------"

echo "Updating NPM"
execute \
    "Failed to update npm" \
    "npm install --only=dev"

echo "Compile SASS files"
execute \
    "Failed to generate css files" \
    "npm run compile-sass"

echo "Building general declarations (without workers)"
execute \
    "Failed to generate declarations" \
    "./scripts/build_declarations.sh"

echo "Building workers"
execute \
    "Failed to build javascript worker" \
    "npm run build-worker"

echo "Building general declarations (with workers)"
execute \
    "Failed to generate declarations" \
    "./scripts/build_declarations.sh"

function move_target_file() {
    file_name=$(ls -1t | grep -E "^TeaWeb-.*\.zip$" | head -n 1)
    if [[ -z "$file_name" ]]; then
        handle_failure "Failed to find target file"
    fi

    target_file="../packages/$file_name"
    if [[ -f "$target_file" ]]; then
        echo "Removing old packed file located at $target_file"
        rm ${target_file} && handle_failure "Failed to remove target file"
    fi
    mv ${file_name} ${target_file}
    echo "Moved target file to $target_file"
}

function execute_build_release() {
    echo "Building release package"
    execute \
        "Failed to build release" \
        "./scripts/web_build.sh release"

    echo "Packaging release"
    execute \
        "Failed to package release" \
        "./scripts/web_package.sh release"

    move_target_file
}
function execute_build_debug() {
    echo "Building debug package"
    execute \
        "Failed to build debug" \
        "./scripts/web_build.sh dev"

    echo "Packaging release"
    execute \
        "Failed to package debug" \
        "./scripts/web_package.sh dev"

    move_target_file
}

if [[ ${build_release} ]]; then
    execute_build_release
fi
if [[ ${build_debug} ]]; then
    execute_build_debug
fi