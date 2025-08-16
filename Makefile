SHELL := /bin/bash

.PHONY: dev up down logs fmt api-tests etl-dev clean install-deps db-reset help

dev: up
	@echo "🚀 Engineering Metrics Dashboard is running!"
	@echo "📊 API docs: http://localhost:8000/docs"
	@echo "🎯 Dashboard: http://localhost:5173"
	@echo "🗄️ Database: localhost:5432"
	@echo ""
	@echo "Press Ctrl+C to stop all services"

up:
	docker compose up --build

down:
	docker compose down -v

logs:
	docker compose logs -f --tail=200

fmt:
	@echo "🔧 Formatting Python code..."
	docker run --rm -v $(PWD)/api:/app -w /app python:3.11 bash -lc "pip install ruff black && ruff check --fix . && black ."
	@echo "🔧 Formatting ETL code..."
	docker run --rm -v $(PWD)/etl:/app -w /app python:3.11 bash -lc "pip install ruff black && ruff check --fix . && black ."

api-tests:
	docker compose exec -T api pytest -q

etl-dev:
	@echo "🔄 Running ETL in development mode..."
	docker compose exec -T etl bash -c "ETL_DEV_MODE=true python -m etl.scheduler"

clean:
	@echo "🧹 Cleaning up..."
	docker compose down -v
	docker system prune -f
	@echo "✅ Cleanup complete"

install-deps:
	@echo "📦 Installing Python dependencies..."
	pip install -r api/requirements.txt
	pip install -r etl/requirements.txt
	@echo "📦 Installing Node.js dependencies..."
	cd dashboard && npm install
	@echo "✅ Dependencies installed"

db-reset:
	@echo "🗄️  Resetting database..."
	docker compose down -v
	docker compose up -d db
	@echo "⏳ Waiting for database to be ready..."
	sleep 10
	@echo "✅ Database reset complete"

help:
	@echo "Engineering Metrics Dashboard - Available Commands:"
	@echo ""
	@echo "🚀 dev          - Start all services and show URLs"
	@echo "⬆️  up           - Start all services"
	@echo "⬇️  down         - Stop all services"
	@echo "📋 logs         - Show service logs"
	@echo "🔧 fmt           - Format Python code"
	@echo "🧪 api-tests     - Run API tests"
	@echo "🔄 etl-dev       - Run ETL in development mode"
	@echo "🧹 clean         - Clean up containers and images"
	@echo "📦 install-deps  - Install dependencies locally"
	@echo "🗄️ db-reset     - Reset database"
	@echo "❓ help          - Show this help message"