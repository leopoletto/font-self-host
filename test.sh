#!/bin/bash

# =============================================================================
# Simple Test Suite for build.sh
# =============================================================================

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    
    ((TESTS_RUN++))
    echo -n "Testing: $test_name... "
    
    if eval "$command" 2>/dev/null | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test function for exit codes
run_test_exit_code() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="$3"
    
    ((TESTS_RUN++))
    echo -n "Testing: $test_name... "
    
    eval "$command" >/dev/null 2>&1
    local actual_exit_code=$?
    
    if [ $actual_exit_code -eq $expected_exit_code ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL (expected $expected_exit_code, got $actual_exit_code)${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "🧪 Running build.sh Test Suite"
echo "================================"

# Test 1: Help command
run_test "Help command" "./build.sh --help" "Font Self-Hosting Preparation Script"

# Test 2: Version command
run_test "Version command" "./build.sh --version" "build.sh v2.0.0"

# Test 3: Invalid option should fail
run_test_exit_code "Invalid option fails" "./build.sh --invalid-option" 1

# Test 4: Missing font directory should fail
run_test_exit_code "Missing font directory fails" "./build.sh --dir /nonexistent" 1

# Test 5: Script should be executable
if [ -x "./build.sh" ]; then
    echo -e "Testing: Script executable... ${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "Testing: Script executable... ${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

# Test 6: Script should have proper shebang
if head -1 "./build.sh" | grep -q "#!/bin/bash"; then
    echo -e "Testing: Proper shebang... ${GREEN}✅ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "Testing: Proper shebang... ${RED}❌ FAIL${NC}"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

# Test 7: Script should handle --no-woff2 option
run_test "No WOFF2 option" "./build.sh --help" "--no-woff2"

# Test 8: Script should handle --verbose option
run_test "Verbose option" "./build.sh --help" "--verbose"

# Test 9: Script should handle --force option
run_test "Force option" "./build.sh --help" "--force"

# Test 10: Script should handle custom directories
run_test "Custom dir option" "./build.sh --help" "--dir DIR"

echo ""
echo "================================"
echo "📊 Test Results:"
echo "   Tests run: $TESTS_RUN"
echo "   Passed: $TESTS_PASSED"
echo "   Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "   Status: ${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "   Status: ${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
