# Determine OS and set default LLVM paths
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    LLVM_DIR ?= /usr/lib/llvm-14
    CLANG ?= /usr/bin/clang
    OPT ?= /usr/bin/opt-14
else ifeq ($(UNAME_S),Darwin)
    LLVM_DIR ?= /opt/homebrew/opt/llvm
    CLANG ?= clang -I/opt/homebrew/opt/llvm/include -isysroot $(shell xcrun --show-sdk-path)
    OPT ?= opt
endif

# Compilation settings
SRC_FILE = inputs/input.c
LLVM_IR_FILE = inputs/input.ll

# Build directory
BUILD_DIR = build

# Default target
all: run

# Setup input files from C source
$(LLVM_IR_FILE): $(SRC_FILE)
	$(CLANG) -S -emit-llvm $(SRC_FILE) -o $(LLVM_IR_FILE) -g -O0

# Create build directory if not exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Configure and build the LLVM pass
build: $(BUILD_DIR)
	cmake -DMY_LLVM_INSTALL_DIR=$(LLVM_DIR) -S . -B $(BUILD_DIR)
	cmake --build $(BUILD_DIR)

# Run the LLVM pass on the generated IR file
run: build $(LLVM_IR_FILE)
	@echo "file_path,branch_id,source_line,destination_line" > branch_data.csv
	$(OPT) -load-pass-plugin $(BUILD_DIR)/BranchPass/libBranchPass.so -passes=branch-analysis-pass -disable-output $(LLVM_IR_FILE)

# Test each file in the 'test' directory
# test: build
# 	@for file in tests/*.c; do \
# 		test_ir="$${file%.c}.ll"; \
# 		$(CLANG) -S -emit-llvm $$file -o $$test_ir -g -O0; \
# 		echo "Running pass on $$test_ir..."; \
# 		$(OPT) -load-pass-plugin $(BUILD_DIR)/BranchPass/libBranchPass.so -passes=branch-analysis-pass -disable-output $$test_ir; \
# 	done
test: build
ifndef FILENAME
	$(error Please specify a file to test, e.g., make test FILENAME=tests/sample.c)
endif
	@echo "file_path,branch_id,source_line,destination_line" > branch_data.csv
	@echo "Testing file: $(FILENAME)"
	test_ir="$(FILENAME:.c=.ll)"; \
	$(CLANG) -S -emit-llvm $(FILENAME) -o $$test_ir -g -O0; \
	echo "Running pass on $$test_ir..."; \
	$(OPT) -load-pass-plugin $(BUILD_DIR)/BranchPass/libBranchPass.so -passes=branch-analysis-pass -disable-output $$test_ir;


# Clean up build artifacts
clean:
	rm -rf $(BUILD_DIR) $(LLVM_IR_FILE) tests/*.ll branch_data.csv

.PHONY: all build run clean
