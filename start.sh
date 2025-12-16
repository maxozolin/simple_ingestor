#!/bin/sh
echo "Starting the application..."

# Load environment variables if .env exists
if [ -f .env ]; then
    echo "Loading .env file..."
    set -a
    source .env
    set +a
fi

# Crash if required environment variables are not defined
if [ -z "$WATCH_DIRECTORY" ]; then
    echo "ERROR: WATCH_DIRECTORY environment variable is not defined. Exiting..."
    exit 1
fi

if [ -z "$OUT_DIRECTORY" ]; then
    echo "ERROR: OUT_DIRECTORY environment variable is not defined. Exiting..."
    exit 1
fi

# Set variables from environment
WATCH_DIR="$WATCH_DIRECTORY"
OUT_DIR="$OUT_DIRECTORY"

# Create out_directory if it doesn't exist
mkdir -p "$OUT_DIR"

# Crash if watch directory doesn't exist
if [ ! -d "$WATCH_DIR" ]; then
    echo "Watch directory does not exist: $WATCH_DIR. Exiting..."
    exit 1
fi

# Crash if out directory doesn't exist
if [ ! -d "$OUT_DIR" ]; then
    echo "Output directory does not exist: $OUT_DIR. Exiting..."
    exit 1
fi

echo "Watching directory: $WATCH_DIR"
echo "Output directory: $OUT_DIR"
echo "Google application credentials: $GOOGLE_APPLICATION_CREDENTIALS"
ls -la $GOOGLE_APPLICATION_CREDENTIALS

echo "Setting up Google Cloud SDK..."
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud config set project $PROJECT_ID

EXTRA_ARGS=""
EXTRA_ARGS="$EXTRA_ARGS $GSUTILS_EXTRA_ARGS"
if [ -n "$GSUTIL_DRY_RUN" ]; then
    EXTRA_ARGS="$EXTRA_ARGS -n"
fi

while true; do
    # Check if there are any files in the watch directory
    if [ -n "$(find "$WATCH_DIR" -type f -name "*" 2>/dev/null | head -1)" ]; then
        echo "Files found in watch directory, moving to GCS..."
        if ! gsutil $EXTRA_ARGS -m mv "${WATCH_DIR}/" "gs://${BUCKET_NAME}/"; then
            echo "ERROR: Failed to move files to GCS. Files remain in watch directory."
        fi
    else
        echo "No files found in watch directory, skipping..."
    fi
    sleep 5
done