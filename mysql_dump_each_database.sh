#!/bin/bash
# Prompt user for MySQL credentials
read -p 'MySQL username: ' USER
read -s -p 'MySQL password: ' PASSWORD
echo

# Set up working directory and target directory
WORK_DIRECTORY=$(pwd)
TARGET_DIRECTORY="mysql_dumps/$(date +%Y%m%d_%H%M)"

# Check if user and password are valid
if ! mysql -u "$USER" -p"$PASSWORD" -e ";" 2>/dev/null; then
    echo -e "\nInvalid MySQL username or password. Exiting."
    exit 1
fi

# Create a new directory and change directory
mkdir -p "$TARGET_DIRECTORY" || { echo "Error: Unable to create target directory. Exiting."; exit 1; }
cd "$TARGET_DIRECTORY" || { echo "Error: Unable to change to target directory. Exiting."; exit 1; }

# Retrieve list of databases
databases=$(mysql -u "$USER" -p"$PASSWORD" -e "SHOW DATABASES;" 2>/dev/null | tr -d "| " | grep -v Database)

# Loop through databases and perform mysqldump
for db in $databases; do
    if [[ "$db" != "information_schema" && "$db" != "performance_schema" && "$db" != "mysql" && "$db" != _* ]]; then
        echo "Dumping database: $db"
        mysqldump -u "$USER" -p"$PASSWORD" --databases "$db" > "$(date +%Y%m%d_%H%M)_$db.sql" 2>&1
        # Consider compressing the dump with gzip if desired
        # gzip "$(date +%Y%m%d_%H%M)_$db.sql"
    fi
done

# Return to the original directory
cd "$WORK_DIRECTORY" || { echo "Error: Unable to change back to the original directory. Exiting."; exit 1; }

# Script execution completed successfully
echo "MySQL database dump completed successfully."
