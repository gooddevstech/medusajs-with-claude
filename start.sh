#!/bin/sh

echo "Running database migrations..."
yarn medusa db:migrate

echo "Seeding database..."
yarn seed || true

echo "Starting Medusa development server..."
yarn dev
