
#!/usr/bin/env bash

set -e

REPO="https://github.com/Abdoalrahmankhedr/Simple-Antivirus-Daemon.git"
PROJECT_DIR="Simple-Antivirus-Daemon"

echo "Installing Simple Antivirus Daemon..."

# Check required tools
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git is not installed."
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "Error: Make is not installed."
    exit 1
fi

# Download the project
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: $PROJECT_DIR already exists."
    echo "Please rename or remove that directory before installing."
    exit 1
fi

git clone "$REPO" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Build or prepare the project
make

echo "Installation completed successfully!"
echo "Project directory: $(pwd)"
