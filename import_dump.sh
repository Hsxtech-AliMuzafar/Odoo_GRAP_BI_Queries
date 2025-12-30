#!/bin/bash

# Utility to import a .sql dump into the postgres container
# The database name is automatically derived from the filename.

DUMP_PATH=$1

if [ -z "$DUMP_PATH" ]; then
    echo "Usage: ./import_dump.sh <path_to_sql_dump>"
    exit 1
fi

if [ ! -f "$DUMP_PATH" ]; then
    echo "Error: File $DUMP_PATH not found."
    exit 1
fi

# Derive database name from filename
# 1. Get basename: e.g., "TCC Dump.sql"
# 2. Remove extension: "TCC Dump"
# 3. Sanitize: "tcc_dump" (lowercase, replace non-alphanumeric with underscores)
DB_NAME=$(basename "$DUMP_PATH")
DB_NAME="${DB_NAME%.*}"
DB_NAME=$(echo "$DB_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//;s/_$//')

if [ -z "$DB_NAME" ]; then
    echo "Error: Could not derive a valid database name from $DUMP_PATH"
    exit 1
fi

echo "Targeting database: $DB_NAME"

# Ensure the database exists
echo "Ensuring database '$DB_NAME' exists..."
docker exec postgres_db psql -U odoo -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database '$DB_NAME' already exists or initialization skipped."

# Copy dump to container
echo "Copying dump to container..."
docker cp "$DUMP_PATH" postgres_db:/tmp/dump.sql

# Import dump
echo "Importing $DUMP_PATH into '$DB_NAME' database..."
docker exec postgres_db psql -U odoo -d "$DB_NAME" -f /tmp/dump.sql

echo "Cleaning up..."
docker exec postgres_db rm /tmp/dump.sql

echo "Import complete."
