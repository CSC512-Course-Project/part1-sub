cmake_minimum_required(VERSION 3.16)

project(BranchPassProfiler)

find_package(LLVM REQUIRED CONFIG)

add_subdirectory(BranchPass)