FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache libc6-compat

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn install

# Copy application files
COPY . .

# Set environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=8000
ENV HOSTNAME="0.0.0.0"

# Expose port
EXPOSE 8000

# Start development server
CMD ["yarn", "dev"]
