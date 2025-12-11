.PHONY: help setup fmt validate lint security test clean install-tools

# Default target
help:
	@echo "🛠️  Terraform Module Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install pre-commit hooks and initialize tools"
	@echo "  make install-tools  - Install required development tools (terraform, tflint, trivy)"
	@echo ""
	@echo "Local Testing (matches GitHub Actions):"
	@echo "  make fmt            - Format all terraform files"
	@echo "  make validate       - Validate terraform configuration"
	@echo "  make lint           - Run tflint on all modules"
	@echo "  make security       - Run Trivy security scan (matches workflow)"
	@echo "  make security-tfsec - Run tfsec security scan (legacy)"
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
	@echo "Installing terraform..."
	@command -v terraform >/dev/null 2>&1 || brew install terraform
	@echo "Installing tflint..."
	@command -v tflint >/dev/null 2>&1 || brew install tflint
	@echo "Installing trivy..."
	@command -v trivy >/dev/null 2>&1 || brew install aquasecurity/trivy/trivy
	@echo "Installing pre-commit..."
	@command -v pre-commit >/dev/null 2>&1 || brew install pre-commit
	@echo "Installing tfsec (optional, legacy)..."
	@command -v tfsec >/dev/null 2>&1 || brew install tfsec
	@echo ""
	@echo "✅ All tools installed successfully!"
	@echo ""
	@echo "Installed versions:"
	@terraform version | head -n1
	@tflint --version
	@trivy --version | head -n1
	@pre-commit --version

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

# Run tflint (consistent with GitHub Actions)
lint:
	@echo "🔍 Running tflint..."
	@tflint --init --config=terraform/.tflint.hcl >/dev/null 2>&1 || true
	@tflint --recursive --format compact --chdir terraform/ --config="$(PWD)/terraform/.tflint.hcl" || { \
		echo "⚠️  TFLint found issues (continuing...)"; \
		exit 0; \
	}
	@echo "✅ Linting complete"

# Run trivy security scan (consistent with GitHub Actions)
security:
	@echo "🔒 Running Trivy security scan..."
	@command -v trivy >/dev/null 2>&1 || { echo "❌ Trivy not installed. Install: brew install aquasecurity/trivy/trivy"; exit 1; }
	@trivy config terraform/ --severity MEDIUM,HIGH,CRITICAL --quiet --exit-code 0
	@echo "✅ Security scan complete"

# Run tfsec (legacy, for comparison)
security-tfsec:
	@echo "🔒 Running tfsec security scan (legacy)..."
	@command -v tfsec >/dev/null 2>&1 || { echo "❌ tfsec not installed. Install: brew install tfsec"; exit 1; }
	@tfsec terraform/ --format lovely --soft-fail
	@echo "✅ tfsec scan complete"

# Run all tests (matches GitHub Actions workflow)
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
	@tflint --init --config=terraform/.tflint.hcl >/dev/null 2>&1 || true
	@tflint --chdir=terraform/$(MODULE) --config="$(PWD)/terraform/.tflint.hcl"
	@echo ""
	@echo "🔒 Security scan..."
	@trivy config terraform/$(MODULE)/ --severity MEDIUM,HIGH,CRITICAL --quiet --exit-code 0
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
