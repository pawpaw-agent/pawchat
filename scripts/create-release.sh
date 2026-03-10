#!/bin/bash

# PawChat Release Script
# Creates a release and triggers automated APK build

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

TAG="v${VERSION}"

echo "🐾 Creating PawChat Release ${TAG}"
echo "======================================"
echo ""

# Update version in pubspec.yaml
echo "Step 1: Updating version in pubspec.yaml..."
# Note: This requires manual edit or yq tool
echo "Please ensure pubspec.yaml has version: ${VERSION}+1"
echo ""

# Commit changes
echo "Step 2: Committing changes..."
git add -A
git commit -m "release: PawChat ${TAG}" || echo "No changes to commit"
git push origin main
echo ""

# Create tag
echo "Step 3: Creating tag ${TAG}..."
git tag -a ${TAG} -m "PawChat ${TAG} - Automated Release"
echo ""

# Push tag (triggers GitHub Actions)
echo "Step 4: Pushing tag to GitHub..."
git push origin ${TAG}
echo ""

echo "✅ Release ${TAG} created!"
echo ""
echo "📦 GitHub Actions is now building APKs..."
echo "⏱️  This will take 5-8 minutes"
echo ""
echo "📊 Monitor progress:"
echo "   https://github.com/pawpaw-agent/pawchat/actions"
echo ""
echo "📦 Release page:"
echo "   https://github.com/pawpaw-agent/pawchat/releases/tag/${TAG}"
echo ""
echo "Once build completes, APKs will be attached to the release!"
