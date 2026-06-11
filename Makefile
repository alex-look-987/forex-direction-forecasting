run:
	uv run main.py

# Help Command

.PHONY: help
help: ## show this help message
	@echo "Available commands:"
	@grep -h -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST)  | \
	awk 'BEGIN {FS = ":.*?## "};  {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# Setup & Environment

.PHONY: install-dev
install-dev: ## install project dependencies (including dev)
	uv sync --all-extras

.PHONY: install-prod
install-prod: ## production dependencies
	uv sync --no-dev

.PHONY: boostrap
boostrap: install-dev ## full project setup
	uv run pre-commit install

# Pre-commit

.PHONY: pre-commit-insstall
pre-commit-run: ## run pre-commit over all file
	uv run pre-commit run --all-files

.PHONY: pre-commit-update
pre-commit-update: ## update hooks latest version
	uv run pre-commit autoupdate

# Cleaning

.PHONY: clean
clean: ## delete build artifacts and python cache
	rm -rf \
	.pytest_cache \
	.mpypy_cache \
	.ruff_cache \
	dist \
	build

	find . -not -path "./.venv/*" -name "__pycache__" -exec rm -rf {} +
	find . -not -path "./.venv/*" -name "*.pyc" -exec rm -f {} +
