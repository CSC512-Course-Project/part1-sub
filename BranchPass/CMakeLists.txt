# Specify minimum CMake version and project metadata
cmake_minimum_required(VERSION 3.16)
project(BranchPassProject VERSION 1.0 LANGUAGES CXX)

# Define custom path to LLVM (adaptable to different platforms)
set(LLVM_CUSTOM_PATH "/opt/homebrew/opt/llvm/" CACHE PATH "Custom path for LLVM installation")

# Add LLVM CMake configuration path for macOS
list(APPEND CMAKE_PREFIX_PATH "${LLVM_CUSTOM_PATH}/lib/cmake/llvm/")

# Configure paths for non-macOS UNIX environments
if(UNIX AND NOT APPLE)
    set(LLVM_LINUX_PATH "/usr/lib/llvm-14")
    list(APPEND CMAKE_PREFIX_PATH "${LLVM_LINUX_PATH}/lib/cmake/llvm/")
    # Remove or comment the vcpkg include since it's not available
    # include(~/tmpdir/vcpkg/scripts/buildsystems/vcpkg.cmake)
endif()

# Locate LLVM with a specific version requirement, output error if minimum version not met
find_package(LLVM CONFIG REQUIRED)
if("${LLVM_VERSION_MAJOR}" VERSION_LESS 14)
    message(FATAL_ERROR "LLVM version 14 or newer is required. Detected LLVM version: ${LLVM_VERSION_MAJOR}")
endif()

# Incorporate LLVM headers as system-level to minimize warnings
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})

# Set project-wide C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable or disable RTTI based on LLVM settings
if(NOT LLVM_ENABLE_RTTI)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
endif()

# Define BranchPass as a dynamically loadable module
add_library(BranchPass MODULE
    BranchPass.cpp
)

# Target-specific compiler features and libraries
target_compile_features(BranchPass PRIVATE cxx_std_17 cxx_range_for cxx_auto_type)

# Link LLVM libraries to BranchPass
target_link_libraries(BranchPass PRIVATE LLVM)

# Display configuration details for user reference
message(STATUS "LLVM found at: ${LLVM_CUSTOM_PATH}")
message(STATUS "Building BranchPass as a module with C++17 standard")
