
cmake_minimum_required(VERSION 3.0)

project(CompileFeatures)

foreach(feature ${CMAKE_CXX_KNOWN_FEATURES})
  if (";${CMAKE_CXX_COMPILE_FEATURES};" MATCHES ${feature})
    list(APPEND test_files ${feature}.cpp)
    list(APPEND test_features ${feature})
  else()
    message("Not supported: ${feature}")
  endif()
endforeach()

if (test_files)
  add_library(test_features OBJECT ${test_files})
  set_property(TARGET test_features
    PROPERTY COMPILE_FEATURES "${test_features}"
  )
endif()

add_executable(CompileFeatures main.cpp)
set_property(TARGET CompileFeatures
  PROPERTY COMPILE_FEATURES "cxx_delegating_constructors"
)

add_executable(GenexCompileFeatures main.cpp)
set_property(TARGET GenexCompileFeatures
  PROPERTY COMPILE_FEATURES "$<1:cxx_delegating_constructors>;$<0:not_a_feature>"
)

add_library(iface INTERFACE)
set_property(TARGET iface
  PROPERTY INTERFACE_COMPILE_FEATURES "cxx_delegating_constructors"
)
add_executable(IfaceCompileFeatures main.cpp)
target_link_libraries(IfaceCompileFeatures iface)
