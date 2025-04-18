
# Test files
TEST_DIR = test
TEST_FILES = $(wildcard $(TEST_DIR)/*.txt)

default: build
	./scanner input.txt

build:
	flex scanner.l
	gcc lex.yy.c -o scanner -lfl

test: build
test: $(EXEC)
	@echo "Running tests..."
	@# Create test directory if it doesn't exist (optional, good practice)
	@mkdir -p $(TEST_DIR)
	@# Check if test files exist
	@if [ -z "$(TEST_FILES)" ]; then \
		echo "WARNING: No test files found in $(TEST_DIR)/. Please create some .txt files."; \
		exit 0; \
	fi
	@# Loop through all test files
	@for test_file in $(TEST_FILES); do \
		echo ""; \
		echo "> Testing with $$test_file:"; \
		cat $$test_file || echo ">>> Error reading $$test_file <<<"; \
		echo ""; \
		./scanner $$test_file; \
	done
	@echo ""
	@echo "All tests finished."

clean:
	rm lex.yy.c scanner test.txt