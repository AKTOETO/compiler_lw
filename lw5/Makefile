# Compiler and flags
CC = gcc
CFLAGS = -Wall -g
LDFLAGS = -lfl

# Flex and flags
FLEX = flex
FFLAGS =

# Bison and flags
BISON = bison
BFLAGS = -d

# Source files
SRC_L = scanner.l
SRC_Y = parser.y

# Generated files
GEN_C_LEX = lex.yy.c
GEN_C_YAC = parser.tab.c
GEN_H_YAC = parser.tab.h

# Executable name
EXEC = parser

# Test files (Assuming they exist in ./test/)
TEST_DIR = ../lw4/test
TEST_FILES = $(wildcard $(TEST_DIR)/*.txt)

# Default target
all: $(EXEC)

# Link the final executable
$(EXEC): $(GEN_C_LEX) $(GEN_C_YAC) $(GEN_H_YAC)
	$(CC) $(CFLAGS) $(GEN_C_LEX) $(GEN_C_YAC) -o $(EXEC) $(LDFLAGS)

# Run Flex (depends on Bison header)
$(GEN_C_LEX): $(SRC_L) $(GEN_H_YAC)
	$(FLEX) $(FFLAGS) $(SRC_L)

# Run Bison (generates .c and .h)
$(GEN_C_YAC) $(GEN_H_YAC): $(SRC_Y)
	$(BISON) $(BFLAGS) $(SRC_Y)

# Run tests
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
		echo "=========================================="; \
		echo "Testing with $$test_file:"; \
		cat $$test_file || echo ">>> Error reading $$test_file <<<"; \
		echo ""; \
		./parser $$test_file; \
	done
	@echo ""
	@echo "All tests finished."

# Clean generated files
clean:
	rm -f $(EXEC) $(GEN_C_LEX) $(GEN_C_YAC) $(GEN_H_YAC) *.o core

.PHONY: all test clean