#!/bin/bash
# Local workflow test script
# Run this before pushing to test what GitHub Actions will check

# Don't exit on error - we want to run all checks
# set -e

EXIT_CODE=0

echo "=========================================="
echo "🎨 Terraform Format Check"
echo "=========================================="
cd terraform
if terraform fmt -check -recursive; then
    echo "✅ Format check passed"
else
    echo "❌ Format check failed"
    echo "Run: terraform fmt -recursive"
    EXIT_CODE=1
fi
echo ""

echo "=========================================="
echo "🔧 Terraform Init"
echo "=========================================="
terraform init -backend=false
echo "✅ Init passed"
echo ""

echo "=========================================="
echo "🤖 Terraform Validate"
echo "=========================================="
if terraform validate -no-color; then
    echo "✅ Validate passed"
else
    echo "❌ Validate failed"
    EXIT_CODE=1
fi
echo ""

echo "=========================================="
echo "🔍 TFLint Analysis"
echo "=========================================="
cd ..
# Initialize tflint plugins
if [ -n "$GITHUB_TOKEN" ]; then
    tflint --init --chdir=terraform || echo "⚠️  TFLint init failed"
else
    echo "ℹ️  Skipping plugin download (set GITHUB_TOKEN to enable)"
    tflint --init --chdir=terraform 2>/dev/null || true
fi

# Run tflint with naming convention enabled and no color
if tflint --recursive --format compact --enable-rule=terraform_naming_convention --minimum-failure-severity=notice --no-color --chdir=terraform; then
    echo "✅ TFLint passed - no issues found"
else
    echo "⚠️  TFLint found issues (see above)"
fi
echo ""

echo "=========================================="
echo "🔒 tfsec Security Scan"
echo "=========================================="
if command -v tfsec &> /dev/null; then
    if tfsec terraform/ --soft-fail --format default --no-color; then
        echo "✅ tfsec passed - no issues found"
    else
        echo "⚠️  tfsec found security issues (see above)"
    fi
else
    echo "⚠️  tfsec not installed. Install: brew install tfsec"
fi
echo ""

echo "=========================================="
echo "📊 Summary"
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All critical checks passed!"
else
    echo "❌ Some checks failed. Please fix the issues above."
fi
echo ""

exit $EXIT_CODE
