.PHONY: help setup fmt validate lint security test clean install-tools

# Default target
help:
	@echo "🛠️  Terraform Module Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install pre-commit hooks and initialize tools"
	@echo "  make install-tools  - Install required development tools (terraform, tflint, tfsec)"
	@echo ""
	@echo "Local Testing:"
	@echo "  make fmt            - Format all terraform files"
	@echo "  make validate       - Validate terraform configuration"
	@echo "  make lint           - Run tflint on all modules"
	@echo "  make security       - Run tfsec security scan"
	@echo "  make test           - Run all tests (fmt, validate, lint, security)"
	@echo ""
	@echo "Pre-commit:"
	@echo "  make pre-commit     - Run pre-commit on all files"
	@echo "  make pre-commit-update - Update pre-commit hooks"
	@echo ""
	@echo "Module Testing:"
	@echo "  make test-module MODULE=<module-name>  - Test specific module"
	@echo "  Example: make test-module MODULE=s3"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          - Clean terraform artifacts"

# Setup development environment
setup:
	@echo "🔧 Setting up development environment..."
	@bash .pre-commit-setup.sh

# Install development tools (macOS with Homebrew)
install-tools:
	@echo "📦 Installing development tools..."
	@command -v brew >/dev/null 2>&1 || { echo "❌ Homebrew not found. Install from https://brew.sh"; exit 1; }
	@command -v terraform >/dev/null 2>&1 || brew install terraform
	@command -v tflint >/dev/null 2>&1 || brew install tflint
	@command -v tfsec >/dev/null 2>&1 || brew install tfsec
	@command -v pre-commit >/dev/null 2>&1 || brew install pre-commit
	@echo "✅ All tools installed"

# Format terraform files
fmt:
	@echo "🎨 Formatting terraform files..."
	@terraform fmt -recursive terraform/
	@echo "✅ Formatting complete"

# Validate terraform configuration
validate:
	@echo "🔍 Validating terraform modules..."
	@for dir in terraform/*/; do \
		if [ -f "$$dir/main.tf" ] && [ "$$(basename $$dir)" != "_template" ]; then \
			echo "Validating $$dir..."; \
			cd "$$dir" && terraform init -backend=false >/dev/null 2>&1 && terraform validate && cd ../..; \
		fi \
	done
	@echo "✅ Validation complete"

# Run tflint
lint:
	@echo "🔍 Running tflint..."
	@tflint --init >/dev/null 2>&1 || true
	@tflint --recursive --format compact --chdir terraform/
	@echo "✅ Linting complete"

# Run tfsec security scan
security:
	@echo "🔒 Running security scan..."
	@tfsec terraform/ --format lovely --soft-fail
	@echo "✅ Security scan complete"

# Run all tests
test: fmt validate lint security
	@echo ""
	@echo "✅ All tests passed!"

# Run pre-commit on all files
pre-commit:
	@echo "🪝 Running pre-commit hooks..."
	@pre-commit run --all-files

# Update pre-commit hooks
pre-commit-update:
	@echo "⬆️  Updating pre-commit hooks..."
	@pre-commit autoupdate

# Test specific module
test-module:
	@if [ -z "$(MODULE)" ]; then \
		echo "❌ Error: MODULE not specified"; \
		echo "Usage: make test-module MODULE=<module-name>"; \
		exit 1; \
	fi
	@if [ ! -d "terraform/$(MODULE)" ]; then \
		echo "❌ Error: Module terraform/$(MODULE) not found"; \
		exit 1; \
	fi
	@echo "🧪 Testing module: $(MODULE)"
	@echo ""
	@echo "📝 Formatting..."
	@terraform fmt terraform/$(MODULE)/
	@echo ""
	@echo "🔍 Validating..."
	@cd terraform/$(MODULE) && terraform init -backend=false && terraform validate
	@echo ""
	@echo "🔍 Linting..."
	@tflint --init >/dev/null 2>&1 || true
	@tflint --chdir=terraform/$(MODULE)
	@echo ""
	@echo "🔒 Security scan..."
	@tfsec terraform/$(MODULE)/ --soft-fail
	@if [ -d "terraform/$(MODULE)/tests/basic" ]; then \
		echo ""; \
		echo "🧪 Running test plan..."; \
		cd terraform/$(MODULE)/tests/basic && \
		terraform init -backend=false && \
		terraform plan; \
	fi
	@echo ""
	@echo "✅ Module $(MODULE) tests complete!"

# Clean terraform artifacts
clean:
	@echo "🧹 Cleaning terraform artifacts..."
	@find terraform -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find terraform -name "*.tfstate*" -delete 2>/dev/null || true
	@find terraform -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find terraform -name "plan.out" -delete 2>/dev/null || true
	@rm -rf .tflint.d/ 2>/dev/null || true
	@echo "✅ Cleanup complete"
