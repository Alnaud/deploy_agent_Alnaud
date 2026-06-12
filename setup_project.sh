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

read -p "Enter project name: " INPUT


if [ -z "$INPUT" ]; then
    echo "Error: Project name cannot be empty!"
    exit 1
fi


PROJECT_DIR="attendance_tracker_${INPUT}"


if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' already exists!"
    exit 1
fi


echo "Creating project structure..."
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"


cp attendance_checker.py "$PROJECT_DIR/attendance_checker.py"
cp assets.csv "$PROJECT_DIR/Helpers/assets.csv"
cp config.json "$PROJECT_DIR/Helpers/config.json"
cp reports.log "$PROJECT_DIR/reports/reports.log"

echo "Directory structure created successfully!"
