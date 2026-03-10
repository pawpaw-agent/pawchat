#!/bin/bash

# PawChat APK Build Script
# This script builds the PawChat Android APK

set -e

echo "🐾 PawChat APK Build Script"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
flutter --version
echo ""

# Check if running in project directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found${NC}"
    echo "Please run this script from the PawChat project root directory"
    exit 1
fi

echo -e "${GREEN}✓ In project directory${NC}"
echo ""

# Install dependencies
echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Generate code (Hive adapters)
echo -e "${YELLOW}Step 2: Generating code (Hive adapters)...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"
echo ""

# Analyze code
echo -e "${YELLOW}Step 3: Analyzing code...${NC}"
flutter analyze
echo -e "${GREEN}✓ Code analysis complete${NC}"
echo ""

# Run tests
echo -e "${YELLOW}Step 4: Running tests...${NC}"
flutter test
echo -e "${GREEN}✓ Tests passed${NC}"
echo ""

# Build debug APK
echo -e "${YELLOW}Step 5: Building debug APK...${NC}"
flutter build apk --debug
echo -e "${GREEN}✓ Debug APK built${NC}"
echo ""

# Build release APK
echo -e "${YELLOW}Step 6: Building release APK...${NC}"
flutter build apk --release
echo -e "${GREEN}✓ Release APK built${NC}"
echo ""

# Output locations
echo "============================"
echo -e "${GREEN}Build Complete!${NC}"
echo ""
echo "Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
echo "Release APK: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo -e "${YELLOW}To install on device:${NC}"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
