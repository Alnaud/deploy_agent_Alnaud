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


# Create the folder structure
echo "Creating project structure..."

# Check write permissions in current directory
if [ ! -w "." ]; then
    echo "Error: No write permission in current directory!"
    exit 1
fi

mkdir -p "$PROJECT_DIR/Helpers" || { echo "Error: Failed to create Helpers directory!"; exit 1; }
mkdir -p "$PROJECT_DIR/reports" || { echo "Error: Failed to create reports directory!"; exit 1; }


cp attendance_checker.py "$PROJECT_DIR/attendance_checker.py"
cp assets.csv "$PROJECT_DIR/Helpers/assets.csv"
cp config.json "$PROJECT_DIR/Helpers/config.json"
cp reports.log "$PROJECT_DIR/reports/reports.log"

echo "Directory structure created successfully!"
# ============ SECTION 3: CONFIG UPDATE WITH SED ============

read -p "Do you want to update attendance thresholds? (yes/no): " ANSWER

if [ "$ANSWER" == "yes" ]; then


    read -p "Enter Warning threshold (default 75): " WARNING


    read -p "Enter Failure threshold (default 50): " FAILURE


    if ! [[ "$WARNING" =~ ^[0-9]+$ ]] || ! [[ "$FAILURE" =~ ^[0-9]+$ ]]; then
        echo "Error: Thresholds must be numbers!"
        exit 1
    fi


    sed -i "s/\"warning\": [0-9]*/\"warning\": $WARNING/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $FAILURE/" "$PROJECT_DIR/Helpers/config.json"

    echo "Thresholds updated successfully!"

else
    echo "Keeping default thresholds."
fi
# ============ SECTION 4: ENVIRONMENT HEALTH CHECK ============

echo "Running environment health check..."

# Check if python3 is installed
if python3 --version 2>/dev/null; then
    echo "Python3 is installed!"
else
    echo "Warning: Python3 is not installed on this system!"
fi


echo "Verifying directory structure..."

if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "Directory structure verified successfully!"
else
    echo "Warning: Some files are missing from the structure!"
fi

echo "Setup complete! Your project is ready at: $PROJECT_DIR"
