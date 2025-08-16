#!/bin/bash

echo "🚀 Engineering Metrics Dashboard - Quick Start"
echo "=============================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose and try again."
    exit 1
fi

echo "✅ Docker environment check passed"
echo ""

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "⚠️  Please edit .env file with your API keys and tokens"
    echo "   - GITHUB_TOKEN: Your GitHub personal access token"
    echo "   - JIRA_*: Your Jira API credentials"
    echo "   - OPENAI_API_KEY: Your OpenAI API key (optional)"
    echo "   - SLACK_*: Your Slack bot credentials (optional)"
    echo ""
    read -p "Press Enter after updating .env file..."
else
    echo "✅ .env file already exists"
fi

echo ""
echo "🔧 Starting services..."
echo "   This may take a few minutes on first run..."
echo ""

# Start the services
docker compose up --build -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 15

# Check if services are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "🎉 Engineering Metrics Dashboard is ready!"
    echo ""
    echo "📊 API Documentation: http://localhost:8000/docs"
    echo "🎯 Dashboard: http://localhost:5173"
    echo "🗄️  Database: localhost:5432"
    echo ""
    echo "📋 Useful commands:"
    echo "   make logs          - View service logs"
    echo "   make down          - Stop all services"
    echo "   make help          - Show all available commands"
    echo ""
    echo "🔍 Check service status:"
    docker compose ps
else
    echo ""
    echo "❌ Some services failed to start. Check logs with:"
    echo "   make logs"
    exit 1
fi
