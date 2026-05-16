#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Helper Functions for Colored Output ---
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

echo "========================================"
echo "   Flutter Project Creator Script       "
echo "========================================"

# --- Dynamic Input Option ---
# Check if a name was passed as an argument (e.g., ./build.sh my_app)
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    # Interactively prompt the user for an input
    DEFAULT_NAME="my_flutter_app"
    read -p "Enter your Flutter project name [$DEFAULT_NAME]: " USER_INPUT
    
    # If the user pressed Enter without typing anything, use the default name
    PROJECT_NAME="${USER_INPUT:-$DEFAULT_NAME}"
fi

# --- Validation Checks ---

# 1. Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    log_error "Flutter SDK could not be found. Please install Flutter and add it to your PATH."
    exit 1
fi

# 2. Validate project name (Flutter requires lowercase letters, numbers, and underscores only)
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9_]+$ ]]; then
    log_error "Invalid project name '$PROJECT_NAME'."
    log_error "Flutter project names must be lowercase alphanumeric characters and underscores only (snake_case)."
    exit 1
fi

# 3. Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    log_error "Directory '$PROJECT_NAME' already exists. Choose a different name or delete the folder."
    exit 1
fi

# --- Project Creation ---
log_info "Creating a normal Flutter project named: $PROJECT_NAME..."

# Creates a standard project with default platforms
flutter create "$PROJECT_NAME"

# Navigate into the project directory
cd "$PROJECT_NAME"

# --- Initial Verification ---
log_info "Fetching initial dependencies..."
flutter pub get

log_info "Verifying project structure by running an analyzer check..."
flutter analyze

echo "----------------------------------------"
log_success "Flutter project '$PROJECT_NAME' has been successfully created!"
log_info "To get started, run the following commands:"
echo -e "\n  cd $PROJECT_NAME"
echo -e "  flutter run\n"
echo "========================================"
