#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# This is the core controller script for generating, building and publishing the   #
# docker containers.                                                               #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# Repo Root                                                                        #
# -------------------------------------------------------------------------------- #
# Work out where the root of the repo is as we need this for reference later.      #
# -------------------------------------------------------------------------------- #

REPO_ROOT=$(r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}" && pwd)
HELPER_ROOT="${REPO_ROOT}/Helpers"
GET_VERSIONS="${HELPER_ROOT}/get-versions.sh"
VERSION_GRABBER="${HELPER_ROOT}/version-grabber.sh"

GET_VERSIONS_URL='https://raw.githubusercontent.com/DockerToolbox/version-helper/master/src/get-versions.sh'
VERSION_GRABBER_URL='https://raw.githubusercontent.com/DockerToolbox/version-helper/master/src/version-grabber.sh'

# -------------------------------------------------------------------------------- #
# Required commands                                                                #
# -------------------------------------------------------------------------------- #
# These commands MUST exist in order for the script to correctly run.              #
# -------------------------------------------------------------------------------- #

PREREQ_COMMANDS=( 'docker' 'md5sum' )

# -------------------------------------------------------------------------------- #
# Global variables                                                                 #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

USE_COLOURS=true
FORCE_TERMINAL=true

GENERATE=false
BUILD=false
CLEAN=false
LATEST=false
PUBLISH=false
GHCR=false
ADDITIONAL_TAGS=""

# -------------------------------------------------------------------------------- #
# Check template                                                                   #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function check_template()
{
    if [[ ! -f "${1}" ]]; then
        abort "${1} is missing aborting Dockerfile generation for ${LOCAL_CONTAINER_PATH}"
    fi
}

# -------------------------------------------------------------------------------- #
# Check file                                                                       #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function check_file()
{
    if [[ ! -f "${REPO_ROOT}/${1}" ]]; then
        abort "${REPO_ROOT}/${1} is missing aborting Dockerfile generation for ${LOCAL_CONTAINER_PATH}"
    fi
}

# -------------------------------------------------------------------------------- #
# File exists                                                                      #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function file_exists()
{
    if [[ ! -f "${REPO_ROOT}/${1}" ]]; then
        return 1
    fi
    return 0
}

# -------------------------------------------------------------------------------- #
# Source file                                                                      #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function source_file()
{
    filename="${1:-}"

    if [[ -n "${filename}" ]]; then
        # shellcheck disable=SC1090,1091
        source "${REPO_ROOT}/${filename}"
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function load_file()
{
    filename="${1:-}"

    if [[ -n "${filename}" ]]; then
        # shellcheck disable=SC1090,1091
        content=$(<"${REPO_ROOT}/${filename}")
        echo "${content}"
    else
        echo ""
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# Escape things that will upset sed - ORDER IF IMPORTANT!!

function escape_string()
{
    local cleaned="${1:-}"

    # Escape \
    # shellcheck disable=SC1003
    cleaned="${cleaned//'\'/'\\'}"

    # Escape "
    # shellcheck disable=SC1003
    cleaned="${cleaned//'"'/'\"'}"

    echo "${cleaned}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function get_git_url()
{
    local url

    url=$(git config --get remote.origin.url)

    without_proto="${url#*:\/\/}"
    without_auth="${without_proto##*@}"

    [[ $without_auth =~ ^([^:\/]+)(:[[:digit:]]+\/|:|\/)?(.*) ]]
    PROJECT_HOST=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
    PROJECT_PATH="${BASH_REMATCH[3]}"
    PROJECT_PATH=${PROJECT_PATH%".git"}
    echo "https://$PROJECT_HOST/$PROJECT_PATH"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function get_ensure_version_grabber_file()
{
    local filename="${1:-}"
    local url="${2:-}"

    if [[ -n "${filename}" ]] && [[ -n "${url}" ]]; then
        curl --silent --output "${filename}" "${url}" && chmod 755 "${filename}"
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function ensure_version_grabber_file()
{
    local filename="${1:-}"
    local url="${2:-}"
    local online_md5
    local local_md5


    if [[ -n "${filename}" ]] && [[ -n "${url}" ]]; then
        if [[ ! -f "${filename}" ]]; then
            get_ensure_version_grabber_file "${filename}" "${url}"
        else
            online_md5="$(curl -sL "${url}" | md5sum | cut -d ' ' -f 1)"
            local_md5="$(md5sum "${filename}" | cut -d ' ' -f 1)"

            if [[ "${online_md5}" != "${local_md5}" ]]; then
                get_ensure_version_grabber_file "${filename}" "${url}"
            fi
        fi
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function ensure_version_grabber()
{
    [ -d "${HELPER_ROOT}" ] || mkdir -p "${HELPER_ROOT}"

    ensure_version_grabber_file "${GET_VERSIONS}" "${GET_VERSIONS_URL}"
    ensure_version_grabber_file "${VERSION_GRABBER}" "${VERSION_GRABBER_URL}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function generate_container()
{
    local container_shell="bash"
    local dockerfile

    info "Generating new Dockerfile for ${LOCAL_CONTAINER_NAME}"

    #
    # Check we have the main Dockerfile template
    #
    check_file "Templates/Dockerfile.tpl"
    dockerfile=$(load_file "Templates/Dockerfile.tpl")
    dockerfile=$(escape_string "${dockerfile}")

    #
    # Check the cleanup template (local symlink)
    #
    if [[ "${SINGLE_OS}" != true ]]; then
        check_template "Templates/cleanup.tpl"
        # shellcheck disable=2034
        CLEANUP=$(<Templates/cleanup.tpl)
    fi

    #
    # Manage the container base shell
    #
    [[ "${CONTAINER_OS_NAME}" == "alpine" ]] && container_shell="ash"

    #
    # Make sure we have the latest helper files
    #
    ensure_version_grabber

    #
    # Calculate the package versions
    #
    # shellcheck disable=2034
    PACKAGES=$("${GET_VERSIONS}" -g "${VERSION_GRABBER}" -p -c "${REPO_ROOT}/Config/packages.cfg" -o "${CONTAINER_OS_NAME}" -t "${CONTAINER_OS_VERSION_ALT}" -s "${container_shell}")

    #
    # Load in the main install template
    #
    check_file "Templates/install.tpl"
    # shellcheck disable=2034
    INSTALL=$(load_file "Templates/install.tpl")

    #
    # Handle the labels - including dynamic ones
    #
    GIT_URL=$(get_git_url)

    LABELS=''
    if file_exists "/Config/labels.cfg"; then
        # shellcheck disable=2034
        LABELS=$(load_file "/Config/labels.cfg")
    fi
    LABELS="${LABELS}\nLABEL org.opencontainers.image.source='${GIT_URL}'\nLABEL org.opencontainers.image.documentation='${GIT_URL}'\n"

    eval "echo -e \"${dockerfile}\"" >| Dockerfile

    info "Complete"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function build_container()
{
    local cmd='docker build '
    local message_prefix

    if [[ "${CLEAN}" = true ]]; then
        message_prefix='Clean building'
        cmd+='--no-cache '
    else
        message_prefix="Building"
    fi
    cmd+="--pull -t ${LOCAL_CONTAINER_NAME} ."

    info "${message_prefix} for ${LOCAL_CONTAINER_NAME}"

    eval "${cmd}"

    info "Complete"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function get_image_id()
{
    local image_id

    image_id=$(docker images -q "${LOCAL_CONTAINER_NAME}")

    if [[ -z "${image_id}" ]]; then
        abort "Unable to locate image ID - aborting"
    fi

    echo "${image_id}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function publish_single_version()
{
    local image_id="${1:-}"
    local tag="${2:-}"

    tag="${tag##*( )}" # Remove leading spaces
    tag="${tag%%*( )}" # Remove trailing spaces

    info "Publishing: ${LOCAL_CONTAINER_NAME} using image ID: ${image_id} to ${PUBLISHED_CONTAINER_NAME_FULL}:${tag}"
    docker tag "${image_id}" "${PUBLISHED_CONTAINER_NAME_FULL}":"${tag}"
    docker push "${PUBLISHED_CONTAINER_NAME_FULL}":"${tag}"
}

function publish_container()
{
    local tag_string=${CONTAINER_OS_VERSION_RAW}
    local image_id

    if [[ "${GHCR}" = true ]]; then
        PUBLISHED_CONTAINER_NAME_FULL="ghcr.io/${GHCR_ORGNAME}/${PUBLISHED_CONTAINER_NAME}"
    else
        PUBLISHED_CONTAINER_NAME_FULL="${DOCKER_HUB_ORG}/${PUBLISHED_CONTAINER_NAME}"
    fi

    tag_string+="${ADDITIONAL_TAGS}"
    if [[ "${LATEST}" = true ]]; then
        tag_string+=',latest'
    fi

    IFS="," read -ra tags <<< "${tag_string}"

    image_id=$(get_image_id)

    for tag in "${tags[@]}"
    do
        publish_single_version "${image_id}" "${tag}"
    done

    info "Complete"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function usage()
{
    [[ -n "${*}" ]] && error "Error: ${*}"

cat <<EOF

  Usage: manage.sh [ -h ] [ options ]

  Valid Options:
      -h | --help     : Print this screen
      -d | --debug    : Debug mode (set -x)
      -b | --build    : Build a container (Optional: -c or --clean)
      -g | --generate : Generate a Dockerfile
      -p | --publish  : Publish a container
      -G | --ghcr     : Publish to Github Container Registry
      -t | --tags     : Add additional tags
EOF
    abort
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function test_getopt
{
    if getopt --test > /dev/null && true; then
        error "'getopt --test' failed in this environment - Please ensure you are using the gnu getopt."
        if [[ "$(uname -s)" == "Darwin" ]]; then
            error "You are using MAcOS - please ensure you have installed gnu-getopt and updated your path."
        fi
        abort
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function process_options()
{
    local options
    local longopts

    if [[ $# -eq 0 ]]; then
        usage
    fi

    test_getopt

    options=hdbcgplGt:
    longopts=help,debug,build,clean,generate,publish,latest,ghcr,tags:

    if ! PARSED=$(getopt --options=$options --longoptions=$longopts --name "$0" -- "$@") && true; then
        usage
    fi
    eval set -- "${PARSED}"
    while true; do
        case "${1}" in
            -h|--help)
                usage
                ;;
            -d|--debug)
                set -x
                shift
                ;;
            -b|--build)
                BUILD=true
                shift
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -g|--generate)
                GENERATE=true
                shift
                ;;
            -p|--publish)
                PUBLISH=true
                shift
                ;;
            -l|--latest)
                LATEST=true
                shift
                ;;
            -G|--ghcr)
                GHCR=true
                shift
                ;;
            -t|--tags)
                ADDITIONAL_TAGS+="${ADDITIONAL_TAGS},${2}"
                shift 2
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    [[ "${GENERATE}" != true ]] && [[ "${BUILD}" != true ]] && [[ "${PUBLISH}" != true ]] &&  usage "You must select generate, build or publish"

    [[ "${GENERATE}" = true ]] && generate_container
    [[ "${BUILD}" = true ]] &&  build_container
    [[ "${PUBLISH}" = true ]] &&  publish_container

    exit 0
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function init_colours()
{
    local ncolors

    fgRed=''
    fgGreen=''
    fgYellow=''
    fgCyan=''
    bold=''
    reset=''

    if [[ "${USE_COLOURS}" = false ]]; then
        return
    fi

    if ! test -t 1; then
        if [[ "${FORCE_TERMINAL}" = true ]]; then
            export TERM=xterm
        else
            return
        fi
    fi

    if ! tput longname > /dev/null 2>&1; then
        return
    fi

    ncolors=$(tput colors)

    if ! test -n "${ncolors}" || test "${ncolors}" -le 7; then
        return
    fi

    fgRed=$(tput setaf 1)
    fgGreen=$(tput setaf 2)
    fgYellow=$(tput setaf 3)
    fgCyan=$(tput setaf 6)

    bold=$(tput bold)
    reset=$(tput sgr0)
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function abort()
{
    notify 'error' "${@}"
    exit 1
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function error()
{
    notify 'error' "${@}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function warn()
{
    notify 'warning' "${@}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function success()
{
    notify 'success' "${@}"
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function info()
{
    notify 'info' "${@}"
}

# -------------------------------------------------------------------------------- #
# Show Warning                                                                     #
# -------------------------------------------------------------------------------- #
# A simple wrapper function to show something was a warning.                       #
# -------------------------------------------------------------------------------- #

function notify()
{
    local type="${1:-}"
    shift
    local message="${*:-}"
    local fgColor

    if [[ -n $message ]]; then
        case "${type}" in
            error)
                fgColor="${fgRed}";
                ;;
            warning)
                fgColor="${fgYellow}";
                ;;
            success)
                fgColor="${fgGreen}";
                ;;
            info)
                fgColor="${fgCyan}";
                ;;
            *)
                fgColor='';
                ;;
        esac
        printf '%s%b%s\n' "${fgColor}${bold}" "${message}" "${reset}" 1>&2
    fi
}

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

function setup_container_details()
{
    local PARTS

    IFS="/" read -ra PARTS <<< "$(pwd)"

    if [[ "${SINGLE_OS}" != true ]]; then
        CONTAINER_OS_NAME=${PARTS[-2]}				# OS name
    else
        CONTAINER_OS_NAME=${SINGLE_OS_NAME}			# OS name
    fi

    CONTAINER_OS_VERSION=${PARTS[-1]}				# Version number
    CONTAINER_OS_VERSION_RAW="${CONTAINER_OS_VERSION}"		# Raw Version
    CONTAINER_OS_VERSION="${CONTAINER_OS_VERSION//./-}"		# Remove .

    if [[ "${NO_OS_NAME_IN_CONTAINER}" = true ]]; then
        CONTAINER_TMP="${CONTAINER_PREFIX}-${CONTAINER_OS_VERSION}"
        PUBLISHED_CONTAINER_NAME="${CONTAINER_PREFIX}"
    else
        CONTAINER_TMP="${CONTAINER_PREFIX}-${CONTAINER_OS_NAME}-${CONTAINER_OS_VERSION}"
        PUBLISHED_CONTAINER_NAME="${CONTAINER_PREFIX}-${CONTAINER_OS_NAME}"
    fi
    LOCAL_CONTAINER_NAME="${CONTAINER_TMP//./-}"

    if [[ "${CONTAINER_OS_NAME}" == "debian" ]]; then
        case "${CONTAINER_OS_VERSION_RAW}" in
            9)
                CONTAINER_OS_VERSION_ALT='stretch'
                ;;
            9-slim)
                CONTAINER_OS_VERSION_ALT='stretch-slim'
                ;;
            10)
                CONTAINER_OS_VERSION_ALT='buster'
                ;;
            10-slim)
                CONTAINER_OS_VERSION_ALT='buster-slim'
                ;;
            11)
                CONTAINER_OS_VERSION_ALT='bullseye'
                ;;
            11-slim)
                CONTAINER_OS_VERSION_ALT='bullseye-slim'
                ;;
            12)
                CONTAINER_OS_VERSION_ALT='bookworm'
                ;;
            12-slim)
                CONTAINER_OS_VERSION_ALT='bookworm-slim'
                ;;
            *)
                abort "Unknown debian version ${CONTAINER_OS_VERSION_RAW} - update core.sh - aborting"
        esac
    else
        CONTAINER_OS_VERSION_ALT=$CONTAINER_OS_VERSION_RAW
    fi
    LOCAL_CONTAINER_PATH="${CONTAINER_OS_NAME}/${CONTAINER_OS_VERSION_RAW}"
}

# -------------------------------------------------------------------------------- #
# Check Prerequisites                                                              #
# -------------------------------------------------------------------------------- #
# Check to ensure that the prerequisite commmands exist.                           #
# -------------------------------------------------------------------------------- #

function check_prereqs()
{
    local error_count=0

    for i in "${PREREQ_COMMANDS[@]}"
    do
        command=$(command -v "${i}" || true)
        if [[ -z $command ]]; then
            warn "${i} is not in your command path"
            error_count=$((error_count+1))
        fi
    done

    if [[ $error_count -gt 0 ]]; then
        abort "${error_count} errors located - fix before re-running";
    fi
}

# -------------------------------------------------------------------------------- #
# Enable strict mode                                                               #
# -------------------------------------------------------------------------------- #
# errexit = Any expression that exits with a non-zero exit code terminates         #
# execution of the script, and the exit code of the expression becomes the exit    #
# code of the script.                                                              #
#                                                                                  #
# pipefail = This setting prevents errors in a pipeline from being masked. If any  #
# command in a pipeline fails, that return code will be used as the return code of #
# the whole pipeline. By default, the pipeline's return code is that of the last   #
# command - even if it succeeds.                                                   #
#                                                                                  #
# noclobber = Prevents files from being overwritten when redirected (>|).          #
#                                                                                  #
# nounset = Any reference to any variable that hasn't previously defined, with the #
# exceptions of $* and $@ is an error, and causes the program to immediately exit. #
# -------------------------------------------------------------------------------- #

function set_strict_mode()
{
    set -o errexit -o noclobber -o nounset -o pipefail
    IFS=$'\n\t'
}

# -------------------------------------------------------------------------------- #
# Main()                                                                           #
# -------------------------------------------------------------------------------- #
# The main function where all of the heavy lifting and script config is done.      #
# -------------------------------------------------------------------------------- #

function main()
{
    set_strict_mode
    init_colours
    source_file "Config/config.cfg"
    setup_container_details
    check_prereqs
    process_options "${@}"
}

# -------------------------------------------------------------------------------- #
# Main()                                                                           #
# -------------------------------------------------------------------------------- #
# This is the actual 'script' and the functions/sub routines are called in order.  #
# -------------------------------------------------------------------------------- #

main "${@}"

# -------------------------------------------------------------------------------- #
# End of Script                                                                    #
# -------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                      #
# -------------------------------------------------------------------------------- #
