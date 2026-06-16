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
#appending codes to attendance_checker.py
cat > attendance_tracker_$input/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
echo " Appended to attendance_checker.py"
#Append codes to assets.csv
cat > attendance_tracker_$input/Helpers/assets.csv << 'EOF'
Email	Names	Attendance Count	Absence Count
alice@example.com	Alice Johnson	14	1
bob@example.com	Bob Smith	7	8
charlie@example.com	Charlie Davis	4	11
diana@example.com	Diana Prince	15	0
EOF
echo " Appended to Helpers/assets.csv"

#Append codes to config.json file
cat > attendance_tracker_$input/Helpers/config.json << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
echo "Appended to Helpers/config.json"

#append codes to reports/reports.log
cat > attendance_tracker_$input/reports/reports.log << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF






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
