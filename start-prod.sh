#!/bin/bash
# Production start script for Medusa backend
# This script starts the Medusa backend for production deployment

set -e

# Load environment variables if .env exists
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Start Medusa backend server
echo "Starting Medusa backend in production mode..."
exec yarn medusa start