# Hostel Management App - Development Commands

.PHONY: help setup start stop test clean

help:
	@echo "Available commands:"
	@echo "  make setup    - Install dependencies"
	@echo "  make start    - Start all services"
	@echo "  make stop     - Stop all services"
	@echo "  make test     - Run all tests"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make migrate  - Run database migrations"
	@echo "  make lint     - Run linters"

setup:
	@echo "Setting up project..."
	cd server && pip install -r requirements.txt
	cd worker && pip install -r requirements.txt
	cd client && flutter pub get

start:
	@echo "Starting services..."
	docker-compose up -d

stop:
	@echo "Stopping services..."
	docker-compose down

test:
	@echo "Running tests..."
	cd server && pytest tests/ -v
	cd worker && pytest tests/ -v
	cd client && flutter test

migrate:
	@echo "Running migrations..."
	cd server && python -m alembic upgrade head

lint:
	@echo "Running linters..."
	cd server && black . && isort . && flake8
	cd worker && black . && isort . && flake8
	cd client && dart analyze && dart format .

clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	cd client && flutter clean
	docker-compose down -v
