#!/usr/bin/env bash

### if .bootstrap exists -> file/folder whitelist active

#set -x
shopt -s nullglob
IFS='\'

function link() {
    local cmd='stow'
    ( $1 ) && cmd='stow\-n'
    for folder in */; do
        if [[ -r $folder.bootstrap ]]; then
            local pcre=$(build_pcre < $folder.bootstrap)
            $cmd -v -t $2 --ignore="$pcre" $folder
        else
            $cmd -v -t $2 $folder
        fi
    done
}

function unlink() {
    local cmd='stow'
    ( $1 ) && cmd='stow\-n'
    for folder in */; do
        $cmd -v -t $2 -D $folder
    done
}

function build_pcre() {
    local files
    readarray -t files
    local delim="|"
    local pcre="$( printf "${delim}%s" "${files[@]}" )"
    pcre="${pcre:${#delim}}" # remove leading delimiter
    echo -n "^(?!^(?:${pcre})$).*$"
}

function main() {
    OPTIND=1
    local run="link"
    local dry=false
    while getopts ":h?dul" opt; do
        case $opt in
        u)
            run="unlink"
            ;;
        l)
            run="link"
            ;;
        d)
            dry=true
            ;;
        h|\?)
            echo "-d for dry-run, -u [path] for unlink, -l [path] for link (default)"
            exit 0
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        esac
    done
    shift $((OPTIND-1))
    [[ "$1" = "--" ]] && shift
    local path=$@
    [[ ! -d $path ]] && path="${XDG_DATA_HOME}/../bin"
    trap "unlink false $path; exit 1" SIGHUP SIGINT SIGTERM
    eval $run $dry $path
}

main "$@"

# EOF
# vim :set ft=sh ts=4 sw=4 sts=4 et :
