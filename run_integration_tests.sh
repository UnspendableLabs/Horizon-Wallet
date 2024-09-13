#!/bin/bash

# Start ChromeDriver
start_chromedriver() {
    echo "Starting ChromeDriver..."
    ./chromedriver/linux-128.0.6613.84/chromedriver-linux64/chromedriver --port=4444 &
    CHROMEDRIVER_PID=$!
    sleep 2  # Give ChromeDriver a moment to start
}

# Find all test files in integration_test/ directory
find_test_files() {
    echo "Finding test files..."
    TEST_FILES=(integration_test/*)
}

# Run integration tests
run_tests() {
    for test_file in "${TEST_FILES[@]}"; do
        test_name=$(basename "$test_file")
        echo "Running test: $test_name"
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target="$test_file" \
            -d chrome

        # Check if the test failed
        if [ $? -ne 0 ]; then
            echo "Test $test_name failed"
            FAILED_TESTS+=("$test_name")
        fi
    done
}

# Clean up
cleanup() {
    echo "Cleaning up..."
    kill $CHROMEDRIVER_PID
    wait $CHROMEDRIVER_PID 2>/dev/null
}

# Main execution
main() {
    FAILED_TESTS=()

    start_chromedriver
    find_test_files
    run_tests
    cleanup

    # Report results
    echo "Test execution completed."
    if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
        echo "All tests passed successfully!"
    else
        echo "The following tests failed:"
        for test in "${FAILED_TESTS[@]}"; do
            echo "- $test"
        done
        exit 1
    fi
}

# Run the main function
main
