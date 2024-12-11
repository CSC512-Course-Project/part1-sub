# Valgrind Branch-Pointer Tracing and Instruction Counting Tool

This project provides tools to trace branch-pointer operations and count the number of executed instructions using Valgrind. It consists of a custom Valgrind tool and necessary files to test and document its functionality.

## Project Structure

```
project-root/
│
├── BranchPass/
│   ├── CMakeLists.txt
│   ├── BranchPass.cpp
├── inputs/
│   ├── input.c
│   └── target (compiled executable from input.c)
├── branch/
│   ├── br_main.c
│   ├── Makefile.am
│   ├── docs/
│   │   └── Makefile.am
│   ├── tests/
│   │   └── Makefile.am
├── valgrind/
│   ├── configure.ac
│   └── Makefile.am
├── README.md
```

## Prerequisites

- Valgrind installed on your system
- LLVM installed (version 14 for UNIX or 16 for macOS)
- CMake (3.16 or newer)
- `g++` compiler

## How to Build and Run

### 1. Build and Run the LLVM Branch Pass

1. Navigate to the `ncsu-csc-512-part1-dev` directory:

   ```bash
   git clone https://github.com/surya-sukumar/ncsu-csc-512-part1-dev.git
   cd ncsu-csc-512-part1-dev
   ```

2. Generate the build files:

   ```bash
   make build
   ```

3. Run the input code:

   ```bash
   make run
   ```

4. To test the BranchPass on custom programs add the program in the tests/ directory and run the below command

   ```bash
   make test FILENAME=tests/<your_progam_name>
   ```

5. To clean your project run the below command
   ```bash
   make clean
   ```
   This will remove all build files and intermediary files created on running the project.

### 2. Build and Run the Valgrind Tool

1. Clone the Valgrind repo and cd into it:

   ```bash
   git clone https://sourceware.org/git/valgrind.git
   cd valgrind
   ```

2. Configure Valgrind with the custom tool:

   ```bash
   ./autogen.sh
   ./configure --prefix=`pwd`/inst
   make install
   ```

3. Go to the project directory and compile the input.c program to create target:

   ```bash
   cd ncsu-csc-512-part1-dev
   cd inputs
   g++ -g -o target input.c
   ```

4. Run the custom Valgrind tool from the valgrind root folder:
   ```bash
   inst/bin/valgrind --tool=branch <path>/<to>/target
   ```

### Output

```bash
==2502571== Branch, a binary profiling tool to count instructions
==2502571== Copyright (C) 2002-2017, and GNU GPL\'d, by Surya Sukumar
==2502571== Using Valgrind-3.23.0.GIT and LibVEX; rerun with -h for copyright info
==2502571== Command: ./input
==2502571==
Foo: 0
Bar: 1
Foo: 2
Bar: 3
==2502571==
==2502571== Total number of executed instructions: 138983
```

For further questions, refer to the [Valgrind Tool Documentation](https://valgrind.org/docs/manual/writing-tools.html).
