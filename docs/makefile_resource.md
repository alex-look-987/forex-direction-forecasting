# Commands

## Boostrap

.PHONY: setup-precommit
setup-precommit: ## registra hooks de pre-commit
	uv run pre-commit install

.PHONY: setup-kernel
setup-kernel: ## registra el kernel de jupyter con nombre del proyecto
	uv run python -m ipykernel install --user \
		--name $(PROJECT_NAME) \
		--display-name "Python ($(PROJECT_NAME))"

.PHONY: setup-jupyter
setup-jupyter: setup-kernel ## configura todo lo relacionado a jupyter
	uv run jupytext --set-formats "notebooks//ipynb,notebooks//py:percent" .

.PHONY: bootstrap
bootstrap: install-dev setup-precommit setup-jupyter ## setup completo
	@echo "✅ Entorno listo"

## Linting & formatting

.PHONY: lint
lint:  ## Corre ruff check
	uv run ruff check .

.PHONY: format
format:  ## Formatea con ruff
	uv run ruff format .

.PHONY: typecheck
typecheck:  ## Type checking con mypy o pyright
	uv run mypy src/

## Testing

.PHONY: test
test:  ## Corre todos los tests
	uv run pytest

.PHONY: test-cov
test-cov:  ## Tests con reporte de cobertura
	uv run pytest --cov=src --cov-report=term-missing --cov-report=html

.PHONY: test-fast
test-fast:  ## Solo tests marcados como 'fast' (excluye lentos/integración)
	uv run pytest -m "not slow"

## Jupyter

.PHONY: notebook
notebook:  ## Lanza Jupyter Lab
	uv run jupyter lab

.PHONY: notebook-clean
notebook-clean:  ## Limpia outputs de todos los notebooks
	uv run jupyter nbconvert --clear-output --inplace notebooks/**/*.ipynb

.PHONY: notebook-run
notebook-run:  ## Ejecuta todos los notebooks headless (smoke test)
	uv run jupyter nbconvert --to notebook --execute notebooks/**/*.ipynb

## Data Pipeline

.PHONY: data-raw
data-raw:  ## Descarga / extrae datos crudos
	uv run python src/data/download.py

.PHONY: data-process
data-process:  ## Procesa datos crudos a interim/processed
	uv run python src/data/process.py

.PHONY: data
data: data-raw data-process  ## Pipeline completo de datos

## Training & evaluation

.PHONY: train
train:  ## Entrena el modelo con config por defecto
	uv run python src/models/train.py

.PHONY: evaluate
evaluate:  ## Evalúa el modelo sobre test set
	uv run python src/models/evaluate.py

.PHONY: pipeline
pipeline: data train evaluate  ## Pipeline end-to-end completo

## Cleaning

.PHONY: clean
clean:  ## Elimina artefactos de build y cache de Python
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name ".pytest_cache" -delete
	find . -type d -name ".mypy_cache" -delete
	find . -type d -name ".ruff_cache" -delete
	rm -rf dist/ build/ *.egg-info

	find . -not -path "./.venv/*" -name ".ipynb_checkpoints" -exec rm -rf {} +

.PHONY: clean-data
clean-data:  ## Elimina datos procesados (no los raw)
	rm -rf data/interim/* data/processed/*

.PHONY: clean-models
clean-models:  ## Elimina modelos entrenados
	rm -rf models/*

## Help (indispensable target)

.PHONY: help
help:  ## Muestra este menú de ayuda
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help