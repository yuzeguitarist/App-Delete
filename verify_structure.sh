#!/bin/bash
# Verification script for Deep Uninstaller project structure

echo "🔍 Verifying Deep Uninstaller project structure..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

errors=0

# Check required directories
echo "📁 Checking directories..."
for dir in Sources Tests docs Sources/Models Sources/Services Sources/Views; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $dir exists"
    else
        echo -e "${RED}✗${NC} $dir missing"
        ((errors++))
    fi
done
echo ""

# Check required source files
echo "📄 Checking source files..."
source_files=(
    "Sources/DeepUninstallerApp.swift"
    "Sources/Models/MonitoringSession.swift"
    "Sources/Services/FSEventsMonitor.swift"
    "Sources/Services/MonitoringSessionManager.swift"
    "Sources/Services/StorageManager.swift"
    "Sources/Views/ContentView.swift"
    "Sources/Views/SessionDetailView.swift"
    "Sources/Views/SessionListView.swift"
    "Sources/Views/WelcomeView.swift"
    "Sources/Views/NewSessionSheet.swift"
)

for file in "${source_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file missing"
        ((errors++))
    fi
done
echo ""

# Check test files
echo "🧪 Checking test files..."
test_files=(
    "Tests/FSEventsMonitorTests.swift"
    "Tests/MonitoredFileTests.swift"
    "Tests/MonitoringSessionManagerTests.swift"
    "Tests/MonitoringSessionTests.swift"
    "Tests/StorageManagerTests.swift"
    "Tests/UIFlowTests.swift"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file missing"
        ((errors++))
    fi
done
echo ""

# Check documentation files
echo "📚 Checking documentation..."
doc_files=(
    "README.md"
    "LICENSE"
    "TODO.md"
    "docs/ARCHITECTURE.md"
    "docs/CHANGELOG.md"
    "docs/CODE_OF_CONDUCT.md"
    "docs/COMPATIBILITY_TESTING.md"
    "docs/CONTRIBUTING.md"
    "docs/DEVELOPMENT.md"
    "docs/INSTALLATION.md"
    "docs/QUICKSTART.md"
    "docs/SECURITY.md"
    "docs/USER_GUIDE.md"
    "docs/UX_IMPROVEMENTS.md"
)

for file in "${doc_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file missing"
        ((errors++))
    fi
done
echo ""

# Check build files
echo "🔧 Checking build configuration..."
if [ -f "Package.swift" ]; then
    echo -e "${GREEN}✓${NC} Package.swift exists"
else
    echo -e "${RED}✗${NC} Package.swift missing"
    ((errors++))
fi

if [ -f "build.sh" ]; then
    echo -e "${GREEN}✓${NC} build.sh exists"
else
    echo -e "${RED}✗${NC} build.sh missing"
    ((errors++))
fi
echo ""

# Check for common issues
echo "🔍 Checking for common issues..."

# Check if old docs are still in root
old_docs=("ARCHITECTURE.md" "CHANGELOG.md" "DEVELOPMENT.md" "INSTALLATION.md")
old_docs_in_root=0
for doc in "${old_docs[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${RED}⚠${NC} $doc should be in docs/ folder, not root"
        ((old_docs_in_root++))
    fi
done

if [ $old_docs_in_root -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No old documentation in root directory"
fi
echo ""

# Summary
echo "================================"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "Project structure is correct."
    exit 0
else
    echo -e "${RED}✗ Found $errors error(s)${NC}"
    echo "Please fix the issues above."
    exit 1
fi
