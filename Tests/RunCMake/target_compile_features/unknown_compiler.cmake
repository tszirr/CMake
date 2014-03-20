
add_library(mylib empty.cpp)
# The unknown compiler doesn't fail on valid features.
target_compile_features(mylib PRIVATE cxx_delegating_constructors)
