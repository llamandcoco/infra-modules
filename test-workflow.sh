#!/bin/bash
# Local workflow test script
# Run this before pushing to test what GitHub Actions will check

set -e

echo "🎨 Testing Terraform Format..."
cd terraform
terraform fmt -check -recursive || {
    echo "❌ Format check failed. Run: terraform fmt -recursive terraform/"
    exit 1
}
echo "✅ Format check passed"
echo ""

echo "🔧 Testing Terraform Init..."
terraform init -backend=false
echo "✅ Init passed"
echo ""

echo "✅ Testing Terraform Validate..."
terraform validate -no-color
echo "✅ Validate passed"
echo ""

echo "🔍 Testing TFLint..."
cd ..
# Initialize tflint plugins (skip if GITHUB_TOKEN not set to avoid rate limits)
if [ -n "$GITHUB_TOKEN" ]; then
    tflint --init || echo "⚠️  TFLint init failed"
else
    echo "ℹ️  Skipping plugin install (set GITHUB_TOKEN to enable)"
fi

# Run tflint with naming convention enabled (produces "notice" level)
tflint --recursive --format compact --enable-rule=terraform_naming_convention --minimum-failure-severity=notice --chdir=terraform || {
    echo "⚠️  TFLint found issues (see above)"
}
echo ""

echo "🔒 Testing tfsec..."
if command -v tfsec &> /dev/null; then
    tfsec terraform/ --soft-fail --format lovely || {
        echo "⚠️  tfsec found issues (see above)"
    }
else
    echo "⚠️  tfsec not installed. Install: brew install tfsec"
fi
echo ""

echo "✅ All checks completed!"
echo ""
echo "If you see any ❌ or ⚠️  above, fix them before pushing."
