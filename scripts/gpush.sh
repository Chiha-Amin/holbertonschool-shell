#!/bin/bash

# Git Auto-Commit-Push Script
# Usage: ./git_commit.sh -m "commit message" [file1] [file2] ... [fileN]

set -e  # Exit immediately on error

# Default values
message=""
files=()
verbose=false
dry_run=false

# Display help
show_help() {
    echo "Usage: $0 -m \"COMMIT_MESSAGE\" [OPTIONS] [FILES...]"
    echo "Options:"
    echo "  -m MESSAGE   Specify commit message (required)"
    echo "  -v           Enable verbose output"
    echo "  -d           Dry run (show actions without executing)"
    echo "  -h           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -m \"Update config\" file1.txt"
    echo "  $0 -m \"Multiple files\" *.js src/*.css"
    echo "  $0 -m \"All changes\"     # Adds all modified files"
    exit 0
}

# Parse command-line options
while getopts ":m:vdh" opt; do
    case $opt in
        m)
            message="$OPTARG"
            ;;
        v)
            verbose=true
            ;;
        d)
            dry_run=true
            verbose=true  # Automatically enable verbose in dry-run mode
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Shift processed options away
shift $((OPTIND - 1))

# Store remaining arguments as files
files=("$@")

# Validate required commit message
if [[ -z "$message" ]]; then
    echo "Error: Commit message is required (-m)" >&2
    show_help
    exit 1
fi

# Show actions (dry-run mode)
if $dry_run; then
    echo "--- DRY RUN MODE ---"
    echo "Commit message: '$message'"
    if [ ${#files[@]} -eq 0 ]; then
        echo "Would run: git add ."
    else
        echo "Would add files:"
        printf '  - %s\n' "${files[@]}"
    fi
    echo "Would run: git commit -m \"$message\""
    echo "Would run: git push"
    exit 0
fi

# Git add operation
if [ ${#files[@]} -eq 0 ]; then
    if $verbose; then echo "Adding all changes..."; fi
    git add .
else
    if $verbose; then 
        echo "Adding specific files:"
        printf '  - %s\n' "${files[@]}"
    fi
    git add "${files[@]}"
fi

# Git commit
if $verbose; then echo "Committing with message: '$message'"; fi
git commit -m "$message"

# Git push
if $verbose; then echo "Pushing to remote repository..."; fi
git push

if $verbose; then echo "Successfully completed all operations!"; fi
