## Bash cheatsheet


# From inside a bash script get hold of the absolute path to the script
# Very useful for calling other scripts that saved in the same directory as the calling script

abspath="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"