#.rst:
# WriteCompilerDetectionHeader
# ----------------------------
#
# Function for generation of compile feature conditionals
#
# This module provides the function write_compiler_detection_header().
#
# The ``GENERATE_EXPORT_HEADER`` function can be used to generate a file
# suitable for preprocessor inclusion which contains macros to be
# used in source code::
#
#    write_compiler_detection_header(
#              FILE <file>
#              PREFIX <prefix>
#              [VERSION <version>]
#              COMPILERS <compiler> [...]
#              FEATURES <feature> [...]
#    )
#
# The ``write_compiler_detection_header`` function generates the
# file ``<file>`` with macros which all have the prefix ``<prefix>``.
#
# ``VERSION`` may be used to specify a generation compatibility with older
# CMake versions.  By default, a file is generated with compatibility with
# the :variable:`CMAKE_MINIMUM_REQUIRED_VERSION`.  Newer CMake versions may
# generate additional code, and the ``VERSION`` may be used to maintain
# compatibility in the generated file while allowing the minimum CMake
# version of the project to be changed indepenendently.
#
# At least one ``<compiler>`` and one ``<feature>`` must be listed.
#
# Feature Test Macros
# ===================
#
# For each compiler, a preprocessor test of the compiler version is generated
# denoting whether the each feature is enabled.  A preprocessor macro
# matching ``${PREFIX}_COMPILER_${FEATURE_NAME_UPPER}`` is generated to
# contain the value ``0`` or ``1`` depending on whether the compiler in
# use supports the feature:
#
# .. code-block:: cmake
#
#    write_compiler_detection_header(
#      FILE climbingstats_compiler_detection.h
#      PREFIX ClimbingStats
#      COMPILERS GNU Clang MSVC
#      FEATURES cxx_variadic_templates
#    )
#
# .. code-block:: c++
#
#    #if ClimbingStats_COMPILER_CXX_VARIADIC_TEMPLATES
#    template<typename... T>
#    void someInterface(T t...) { /* ... */ }
#    #else
#    // Compatibility versions
#    template<typename T1>
#    void someInterface(T1 t1) { /* ... */ }
#    template<typename T1, typename T2>
#    void someInterface(T1 t1, T2 t2) { /* ... */ }
#    template<typename T1, typename T2, typename T3>
#    void someInterface(T1 t1, T2 t2, T3 t3) { /* ... */ }
#    #endif
#
# Symbol Macros
# =============
#
# Some additional symbol-defines are created for particular features for
# use as symbols which are conditionally defined empty. The macros for
# such symbol defines match ``${PREFIX}_DECL_${FEATURE_NAME_UPPER}``:
#
# .. code-block:: c++
#
#    class MyClass ClimbingStats_DECL_CXX_FINAL
#    {
#        ClimbingStats_DECL_CXX_CONSTEXPR int someInterface() { return 42; }
#    };
#
# The ``ClimbingStats_DECL_CXX_FINAL`` macro will expand to ``final`` if the
# compiler (and its flags) support the ``cxx_final`` feature, and the
# ``ClimbingStats_DECL_CXX_CONSTEXPR`` macro will expand to ``constexpr``
# if ``cxx_constexpr`` is supported.
#
# In the case of the ``cxx_final`` feature with a version of MSVC which
# does not support ``final``, the ``ClimbingStats_DECL_CXX_FINAL`` macro
# expands to ``sealed`` if using a MSVC version which supports that
# extension.  The MSVC ``sealed`` keyword is an extension which is
# supported in the same position and meaning as the standardised ``final``
# keyword.
#
# The following features generate corresponding symbol defines:
#
# * ``cxx_final``
# * ``cxx_override``
# * ``cxx_constexpr``
#
# Compatibility Implemetation Macros
# ==================================
#
# Some features are suitable for wrapping in a macro with a backward
# compatibility implementation if the compiler does not support the feature.
#
# When the ``cxx_static_assert`` feature is not provided by the compiler,
# a compatibility implementation is available via the
# ``${PREFIX}_STATIC_ASSERT`` and ``${PREFIX}_STATIC_ASSERT_MSG``
# function-like macros. The macros expand to ``static_assert`` where that
# compiler feature is available, and to a compatibility implementation
# otherwise.

#=============================================================================
# Copyright 2013 Stephen Kelly <steveire@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

include(${CMAKE_CURRENT_LIST_DIR}/CMakeParseArguments.cmake)

function(_load_compiler_variables CompilerId lang)
  include("${CMAKE_ROOT}/Modules/Compiler/${CompilerId}-${lang}-FeatureTests.cmake" OPTIONAL)
  if (NOT _cmake_compiler_test_macro)
    message(FATAL_ERROR "Compiler ${CompilerId} does not define _cmake_compiler_test_macro")
  endif()
  set(COMPILER_TEST_${CompilerId} "${_cmake_compiler_test_macro}" PARENT_SCOPE)
  foreach(feature ${ARGN})
    set(_cmake_feature_test_${CompilerId}_${feature} ${_cmake_feature_test_${feature}} PARENT_SCOPE)
    if (_cmake_symbol_alternative_${feature})
      set(_cmake_symbol_alternative_${CompilerId}_${feature} ${_cmake_symbol_alternative_${feature}} PARENT_SCOPE)
      set(_cmake_symbol_alternative_test_${CompilerId}_${feature} ${_cmake_symbol_alternative_test_${feature}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(write_compiler_detection_header
    file_keyword file_arg
    prefix_keyword prefix_arg
    )
  if (NOT file_keyword STREQUAL FILE)
    message(FATAL_ERROR "Wrong parameters for function.")
  endif()
  if (NOT prefix_keyword STREQUAL PREFIX)
    message(FATAL_ERROR "Wrong parameters for function.")
  endif()
  set(options)
  set(oneValueArgs VERSION)
  set(multiValueArgs COMPILERS FEATURES)
  cmake_parse_arguments(_WCD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT _WCD_COMPILERS OR NOT _WCD_FEATURES)
    message(FATAL_ERROR "Invalid arguments.")
  endif()

  if(_WCD_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unparsed arguments: ${_WCD_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT _WCD_VERSION)
    set(_WCD_VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})
  endif()
#   if (_WCD_VERSION VERSION_LESS 3.0.0) # Version which introduced this function
#     message(FATAL_ERROR "VERSION parameter too low.")
#   endif()
  cmake_policy(GET CMP0025 setting_25)
  if(NOT setting_25 STREQUAL NEW)
    message(FATAL_ERROR "Policy CMP0025 must be NEW to use this function.")
  endif()
  cmake_policy(GET CMP0046 setting_46)
  if(NOT setting_46 STREQUAL NEW)
    message(FATAL_ERROR "Policy CMP0046 must be NEW to use this function.")
  endif()

  set(ordered_compilers
    # Order is relevant here. We need to list the compilers which pretend to
    # be GNU/MSVC before the actual GNU/MSVC compiler.
    QCC
    Clang
    GNU
    MSVC
  )
  foreach(_comp ${_WCD_COMPILERS})
    list(FIND ordered_compilers ${_comp} idx)
    if (idx EQUAL -1)
      message(FATAL_ERROR "Unsupported compiler ${_comp}.")
    endif()
  endforeach()

  file(WRITE ${file_arg} "
// This is a generated file. Do not edit!

#ifndef ${prefix_arg}_COMPILER_DETECTION_H
#define ${prefix_arg}_COMPILER_DETECTION_H

#if !defined (__clang__)
#  define __has_extension(ext) 0
#endif
")

  foreach(_lang CXX)

    if(_lang STREQUAL CXX)
      file(APPEND "${file_arg}" "\n#ifdef __cplusplus\n")
    endif()

    set(pp_if "if")
    foreach(ordered_compiler ${ordered_compilers})
      list(FIND _WCD_COMPILERS ${ordered_compiler} idx)
      if (NOT idx EQUAL -1)
        _load_compiler_variables(${ordered_compiler} ${_lang} ${_WCD_FEATURES})
        file(APPEND "${file_arg}" "\n#  ${pp_if} ${COMPILER_TEST_${ordered_compiler}}\n")
        set(pp_if "elif")
        foreach(feature ${_WCD_FEATURES})
          list(FIND CMAKE_${_lang}_KNOWN_FEATURES ${feature} idx)
          if (NOT idx EQUAL -1)
            set(_define_check "\n#    define ${prefix_arg}_${CMAKE_PP_NAME_${feature}} 0\n")
            if (_cmake_feature_test_${ordered_compiler}_${feature} STREQUAL "1")
              set(_define_check "\n#    define ${prefix_arg}_${CMAKE_PP_NAME_${feature}} 1\n")
            elseif (_cmake_feature_test_${ordered_compiler}_${feature})
              set(_define_check "\n#      define ${prefix_arg}_${CMAKE_PP_NAME_${feature}} 0\n")
              set(_define_check "\n#    if ${_cmake_feature_test_${ordered_compiler}_${feature}}\n#      define ${prefix_arg}_${CMAKE_PP_NAME_${feature}} 1\n#    else${_define_check}#    endif\n")
            endif()
            file(APPEND "${file_arg}" "${_define_check}")
          endif()
        endforeach()
      endif()
    endforeach()
    if(pp_if STREQUAL "elif")
      file(APPEND "${file_arg}" "\n#  else\n")
      foreach(feature ${_WCD_FEATURES})
        file(APPEND "${file_arg}" "\n#    define ${prefix_arg}_${CMAKE_PP_NAME_${feature}} 0\n")
      endforeach()
      file(APPEND "${file_arg}" "\n#  endif\n\n")
    endif()
    foreach(feature ${_WCD_FEATURES})
      set(def_value ${CMAKE_SYMBOL_DEFINE_${feature}})
      if (def_value)
        set(def_name ${prefix_arg}_${CMAKE_PP_DECL_${feature}})
        foreach(ordered_compiler ${ordered_compilers})
          if (_cmake_symbol_alternative_test_${ordered_compiler}_${feature})
            set(alternatives "${alternatives}#  elif ${_cmake_symbol_alternative_test_${ordered_compiler}_${feature}}\n#    define ${def_name} ${_cmake_symbol_alternative_${ordered_compiler}_${feature}}\n")
          endif()
        endforeach()
        file(APPEND "${file_arg}" "#  if ${prefix_arg}_${CMAKE_PP_NAME_${feature}}\n#    define ${def_name} ${def_value}\n${alternatives}#  else\n#    define ${def_name}\n#  endif\n\n")
      endif()
    endforeach()
    foreach(feature ${_WCD_FEATURES})
      if (feature STREQUAL cxx_static_assert)
        set(def_name ${prefix_arg}_${CMAKE_PP_NAME_cxx_static_assert})
        set(def_value "${prefix_arg}_STATIC_ASSERT(X)")
        set(def_value_msg "${prefix_arg}_STATIC_ASSERT_MSG(X, MSG)")
        set(static_assert_struct "template<bool> struct ${prefix_arg}StaticAssert;\ntemplate<> struct ${prefix_arg}StaticAssert<true>{};\n")
        set(def_standard "#    define ${def_value} static_assert(X, #X)\n#    define ${def_value_msg} static_assert(X, MSG)")
        set(def_alternative "${static_assert_struct}#    define ${def_value} sizeof(CMakeStaticAssert<X>)\n#    define ${def_value_msg} sizeof(CMakeStaticAssert<X>)")
        file(APPEND "${file_arg}" "#  if ${def_name}\n${def_standard}\n#  else\n${def_alternative}\n#  endif\n\n")
      endif()
    endforeach()
    if(_lang STREQUAL CXX)
      file(APPEND "${file_arg}" "#endif\n")
    endif()

  endforeach()

  file(APPEND ${file_arg} "\n#endif\n")
endfunction()
