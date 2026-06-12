#!/bin/bash


PROJECT_DIR=""


cleanup() {
    echo ""
    echo "Interrupt detected! Cleaning up..."

    # Only archive if the directory was already created
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        echo "Archiving incomplete project..."
        tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR"
        echo "Archive created: ${PROJECT_DIR}_archive.tar.gz"

        echo "Deleting incomplete directory..."
        rm -rf "$PROJECT_DIR"
        echo "Cleanup done. Exiting."
    fi

    exit 1
}


trap cleanup SIGINT
