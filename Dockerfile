FROM node:20-alpine

# Install system dependencies
RUN apk add --no-cache libc6-compat

# Set working directory
WORKDIR /server

# Copy package files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn install

# Copy application files
COPY . .

# Make start script executable
RUN chmod +x start.sh

# Expose ports
EXPOSE 9000 5173

# Run the startup script
CMD ["./start.sh"]
