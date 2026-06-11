makefilePROJECT_NAME := $(shell uv run python -c \
	"import tomllib; print(tomllib.load(open('pyproject.toml','rb'))['project']['name'])")

# Help

.PHONY: help
help: ## show this help message
	@echo "Available commands:"
	@grep -h -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST)  | \
	awk 'BEGIN {FS = ":.*?## "};  {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# Setup & Environment

.PHONY: check-uv
check-uv: ## checking if uv already install
	@command -v uv >/dev/null 2>&1 || \
		{ echo "uv no instalado: https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }

.PHONY: install-dev
install-dev: ## install project dependencies (including dev)
	uv sync --all-extras

.PHONY: install-prod
install-prod: ## production dependencies
	uv sync --no-dev

.PHONY: bootstrap
bootstrap: check-uv install-dev ## full project setup
	uv run pre-commit install
	@echo "setup environment"

# Run

.PHONY: run
run: ## run main script
	uv run main.py


# Pre-commit

.PHONY: pre-commit-run
pre-commit-run: ## run pre-commit over all files
	uv run pre-commit run --all-files

.PHONY: pre-commit-update
pre-commit-update: ## update hooks latest version
	uv run pre-commit autoupdate

# Cleaning

.PHONY: clean
clean: ## delete build artifacts and python cache
	rm -rf \
	.pytest_cache \
	.mypy_cache \
	.ruff_cache \
	dist \
	build

	find . -not -path "./.venv/*" -name "__pycache__" -exec rm -rf {} +
	find . -not -path "./.venv/*" -name "*.pyc" -exec rm -f {} +
