
add_library(iface INTERFACE)

add_library(iface2 INTERFACE)
target_compile_features(iface2 INTERFACE msvcxx_sealed)

add_executable(my_exe empty.cpp)
target_link_libraries(my_exe $<$<HAVE_COMPILER_FEATURE:msvcxx_sealed>:iface> iface2)
