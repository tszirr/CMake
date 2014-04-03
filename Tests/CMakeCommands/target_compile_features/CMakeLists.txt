cmake_minimum_required(VERSION 3.0)
project(target_compile_features)

set(CMAKE_VERBOSE_MAKEFILE ON)

add_executable(target_compile_features main.cpp)
target_compile_features(target_compile_features
  PRIVATE cxx_delegating_constructors
)

add_library(lib_delegating_constructors lib_delegating_constructors.cpp)
target_compile_features(lib_delegating_constructors
  PUBLIC cxx_delegating_constructors
)

add_executable(lib_user lib_user.cpp)
target_link_libraries(lib_user lib_delegating_constructors)
