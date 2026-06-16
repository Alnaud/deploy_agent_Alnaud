# deploy_agent_Alnaud

## Description
A shell script that automates the creation of a Student Attendance Tracker workspace.

## How to Run the Script

1. Clone the repository:
   git clone git@github.com:Alnaud/deploy_agent_Alnaud.git

2. Navigate into the directory:
   cd deploy_agent_Alnaud

3. Make the script executable:
   chmod +x setup_project.sh

4. Run the script:
   bash setup_project.sh

5. Follow the prompts:
   - Enter a project name
   - Choose whether to update attendance thresholds
   - Enter numeric values for Warning and Failure thresholds

## How to Trigger the Archive Feature

1. Run the script: bash setup_project.sh
2. Enter a project name and press Enter
3. Press Ctrl+C at any prompt during execution
4. The script will automatically:
   - Bundle the incomplete project into an archive file
   - Delete the incomplete directory
   - Exit cleanly

## Requirements
- bash
- python3

Video link https://drive.google.com/file/d/1ZJwsMzZOTZMpRIN8U0rM7yPDaKpXrnoo/view?usp=sharing
