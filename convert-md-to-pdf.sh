#!/bin/bash

# Check for help option
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $(basename "$0") [directory]"
  echo "Convert all Markdown (.md) files in the specified directory and its subdirectories to PDF using the Skia engine."
  echo "If no directory is specified, the current working directory will be used."
  echo ""
  echo "Examples:"
  echo "  $(basename "$0")  # Convert all Markdown files in the current working directory and its subdirectories"
  echo "  $(basename "$0") /path/to/your/directory  # Convert all Markdown files in the specified directory and its subdirectories"
  echo "  $(basename "$0") ./subdirectory  # Convert all Markdown files in the subdirectory of the current working directory and its subdirectories"
  exit 0
fi

# Check for operating system
os=""
case "$(uname -s)" in
  Linux*) os="Linux";;
  Darwin*) os="Mac";;
  *) echo "Unsupported OS. Please use Linux or macOS."; exit 1;;
esac

# Check if Node.js is installed, and install it if it's missing
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required but not installed."
  if [ "$os" == "Linux" ]; then
    echo "Installing Node.js..."
    if [ -f /etc/redhat-release ]; then
      # RHEL-based systems
      sudo yum install -y epel-release
      sudo yum install -y nodejs
    else
      # Debian-based systems
      curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
      sudo apt-get install -y nodejs
    fi
  elif [ "$os" == "Mac" ]; then
    echo "Installing Node.js using Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew install node
  fi
fi

# Check if npm is installed, and install it if it's missing
if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required but not installed."
  if [ "$os" == "Linux" ]; then
    echo "Installing npm..."
    if [ -f /etc/redhat-release ]; then
      # RHEL-based systems
      sudo yum install -y npm
    else
      # Debian-based systems
      sudo apt-get install -y npm
    fi
  elif [ "$os" == "Mac" ]; then
    echo "Installing npm using Homebrew..."
    brew install npm
  fi
fi

# Install md-to-pdf if it's not installed
if ! command -v md-to-pdf >/dev/null 2>&1; then
  echo "Installing md-to-pdf..."
  npm install -g md-to-pdf
  if [ $? -ne 0 ]; then
    echo "Error installing md-to-pdf. Please check your npm permissions and try again."
    exit 1
  fi
fi

# Set the working directory
if [ -z "$1" ]; then
  dir="."
else
  dir="$1"
fi

# Convert Markdown files to PDF
find "$dir" -type f -iname "*.md" -exec sh -c 'md-to-pdf "{}" && echo "Converted: {}"' \;

if [ $? -eq 0 ]; then
  echo "Conversion completed successfully."
else
  echo "An error occurred during the conversion process."
  exit 1
fi
