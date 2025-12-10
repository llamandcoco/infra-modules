#!/bin/bash
# Pre-commit setup script for local development

set -e

echo "🔧 Setting up pre-commit hooks for terraform..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "❌ pre-commit is not installed"
    echo ""
    echo "Install with one of the following:"
    echo "  • pip install pre-commit"
    echo "  • brew install pre-commit"
    echo "  • pipx install pre-commit"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "⚠️  Warning: terraform is not installed"
    echo "   Install from: https://www.terraform.io/downloads"
fi

# Check if tflint is installed
if ! command -v tflint &> /dev/null; then
    echo "⚠️  Warning: tflint is not installed"
    echo "   Install with: brew install tflint"
    echo "   Or visit: https://github.com/terraform-linters/tflint"
fi

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "⚠️  Warning: trivy is not installed"
    echo "   Install with: brew install trivy"
    echo "   Or visit: https://github.com/aquasecurity/trivy"
fi

# Install pre-commit hooks
echo ""
echo "📦 Installing pre-commit hooks..."
pre-commit install

# Initialize tflint plugins
if command -v tflint &> /dev/null; then
    echo ""
    echo "🔌 Initializing tflint plugins..."
    tflint --init
fi

echo ""
echo "✅ Pre-commit hooks installed successfully!"
echo ""
echo "📝 Usage:"
echo "  • Hooks will run automatically on 'git commit'"
echo "  • To run manually: pre-commit run --all-files"
echo "  • To skip hooks: git commit --no-verify (not recommended)"
echo "  • To update hooks: pre-commit autoupdate"
echo ""
echo "🧪 Testing pre-commit setup..."
pre-commit run --all-files || true

echo ""
echo "🎉 Setup complete! Pre-commit will now run on every commit."
