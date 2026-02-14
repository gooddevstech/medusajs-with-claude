#!/bin/sh

# Wait for backend to be ready
sleep 5

# Login as admin
TOKEN=$(curl -s -X POST http://localhost:9000/auth/user/emailpass \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@medusa.test","password":"supersecret"}' \
  | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$TOKEN" ]; then
  echo "Failed to login. Please ensure admin user exists."
  exit 1
fi

# Create publishable API key
RESPONSE=$(curl -s -X POST http://localhost:9000/admin/publishable-api-keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"Storefront"}')

echo "$RESPONSE"

# Extract the key
KEY=$(echo "$RESPONSE" | grep -o '"id":"pk_[^"]*' | sed 's/"id":"//')

if [ -n "$KEY" ]; then
  echo ""
  echo "Publishable API Key created: $KEY"
  echo ""
  echo "Add this to storefront/.env.local:"
  echo "NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$KEY"
else
  echo "Failed to create key. Response: $RESPONSE"
fi
