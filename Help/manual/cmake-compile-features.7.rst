.. cmake-manual-description: CMake Compile Features Reference

cmake-compile-features(7)
*************************

.. only:: html or latex

   .. contents::

Introduction
============

Project source code may depend on, or be conditional on, the availability
of certain features of the compiler.  There are three use-cases which arise:
`Compile Feature Requirements`_, `Optional Compile Features`_
and `Conditional Compilation Options`_.

While features are typically specified in programming language standards,
CMake provides a primary user interface based on handling the features,
not the language standard that introduced the feature.

The :variable:`CMAKE_CXX_KNOWN_FEATURES` variable contains all the features
known to CMake, regardless of compiler support for the feature.  The
:variable:`CMAKE_CXX_COMPILE_FEATURES` variable contains all features
known to the compiler, regardless of language standard or compile flags
needed to use them.

Features known to CMake are named mostly following the same convention
as the clang feature test macros.  The are some execptions, such as
CMake using ``cxx_final`` and ``cxx_override`` instead of the single
``cxx_override_control`` used by clang.  Compiler-specific extensions
are named with a prefix denoting the id of the compiler, such as
``gnuxx_typeof`` and ``msvcxx_sealed``.

Compile Feature Requirements
============================

Compile feature requirements may be specified with the
:command:`target_compile_features` command.  For example, if a target must
be compiled with compiler support for the
:variable:`cxx_constexpr <CMAKE_CXX_KNOWN_FEATURES>` feature:

.. code-block:: cmake

  add_library(mylib requires_constexpr.cpp)
  target_compile_features(mylib PRIVATE cxx_constexpr)

In processing the requirement for the ``cxx_constexpr`` feature,
:manual:`cmake(1)` will ensure that the in-use C++ compiler is capable
of the feature, and will add any necessary flags such as ``-std=c++11``
to the compile lines of C++ files in the ``mylib`` target.  A
``FATAL_ERROR`` is issued if the compiler is not capable of the
feature.

The exact compile flags and language standard are deliberately not part
of the user interface for this use-case.  CMake will compute the
appropriate compile flags to use by considering the features specified
for each target.  For example, a target may require the ``cxx_constexpr``
feature, and CMake will add the ``-std=c++11`` flag if using GNU. A
target may require the ``gnuxx_typeof`` feature, a GNU extension
which requires the ``-std=gnu++98`` flag. If the target additionally
requires the ``cxx_constexpr`` feature, then the ``-std=gnu++11`` flag
will be used instead of ``-std=c++11`` for that compiler.

Such compile flags are added even if the compiler supports the
particular feature without the flag. For example, the GNU compiler
supports variadic templates (with a warning) even if ``-std=c++98`` is
used.  CMake adds the ``-std=c++11`` flag if ``cxx_variadic_templates``
is specified as a requirement.

In the above example, ``mylib`` requires ``cxx_constexpr`` when it
is built itself, but consumers of ``mylib`` are not required to use a
compiler which supports ``cxx_constexpr``.  If the interface of
``mylib`` does require the ``cxx_constexpr`` feature (or any other
known feature), that may be specified with the ``PUBLIC`` or
``INTERFACE`` signatures of :command:`target_compile_features`:

.. code-block:: cmake

  add_library(mylib requires_constexpr.cpp)
  target_compile_features(mylib PUBLIC cxx_constexpr)

  # main.cpp will be compiled with -std=c++11 on GNU for cxx_constexpr.
  add_executable(myexe main.cpp)
  target_link_libraries(myexe mylib)

  # gnu_main.cpp will be compiled with -std=gnu++11 on GNU
  # for cxx_constexpr and gnuxx_typeof combined.
  add_executable(myextenstion_exe gnu_main.cpp)
  target_link_libraries(myextenstion_exe mylib)
  target_compile_features(myextenstion_exe PRIVATE gnuxx_typeof)

Feature requirements are evaluated transitively by consuming the link
implementation.  See :manual:`cmake-buildsystem(7)` for more on
transitive behavior of build properties.

Note that new use of compile feature requirements may expose
cross-platform bugs in user code.  For example, the GNU compiler uses the
``gnu++98`` language by default as of GCC version 4.8.  User code may
be relying on that and expecting the ``typeof`` extension to work.
However, if the :command:`target_compile_features` command is used to
specify the requirement for ``cxx_constexpr``, a ``-std=c++11`` flag may
be added, and the ``typeof`` extension would no longer be available. The
solution is to specify extensions which are relied upon when starting to
use the :command:`target_compile_features` command and, in this case,
specify the ``gnuxx_typeof`` feature too.

If the compiler in use is newer than the :manual:`cmake(1)` in use, the
compiler may support features which are not recorded as supported by
CMake.  In such cases, if the version of CMake generally
:variable:`supports <CMAKE_CXX_KNOWN_FEATURES>`, the feature, it is
possible to extend the :variable:`CMAKE_CXX_COMPILE_FEATURES` variable
to allow use of the compiler feature. For example:

.. code-block:: cmake

  cmake_minimum_required(VERSION 3.2)

  if (NOT MSVC_VERSION VERSION_LESS 1900
      # CMake 3.3 records support for this feature. Add it temporarily
      # as a workaround here.
      AND CMAKE_VERSION VERSION_LESS 3.3)
    list(APPEND CMAKE_CXX_COMPILE_FEATURES cxx_some_known_feature)
  endif()

  add_library(some_lib some_lib.cpp)
  target_compile_features(some_lib PRIVATE
    cxx_some_known_feature) # No error with MSVC 1900 and CMake 3.2.


Optional Compile Features
=========================

Compile features may be preferred if available, without creating a hard
requirement.  For example, a library may provides alternative
implementations depending on whether the ``cxx_variadic_templates``
feature is available:

.. code-block:: c++

  #if Foo_COMPILER_CXX_VARIADIC_TEMPLATES
  template<int I, int... Is>
  struct Interface;

  template<int I>
  struct Interface<I>
  {
    static int accumulate()
    {
      return I;
    }
  };

  template<int I, int... Is>
  struct Interface
  {
    static int accumulate()
    {
      return I + Interface<Is...>::accumulate();
    }
  };
  #else
  template<int I1, int I2 = 0, int I3 = 0, int I4 = 0>
  struct Interface
  {
    static int accumulate() { return I1 + I2 + I3 + I4; }
  };
  #endif

Such an interface depends on using the correct preprocessor defines for the
compiler features.  CMake can generate a header file containing such
defines using the :module:`WriteCompilerDetectionHeader` module.  The
module contains the ``write_compiler_detection_header`` function which
accepts parameters to control the content of the generated header file:

.. code-block:: cmake

  write_compiler_detection_header(
    FILE "${CMAKE_CURRENT_BINARY_DIR}/foo_compiler_detection.h"
    PREFIX Foo
    COMPILERS GNU Clang MSVC
    FEATURES
      cxx_variadic_templates
  )

Such a header file may be used internally in the source code of a project,
and it may be installed and used in the interface of library code.

For each feature listed in ``FEATURES``, a preprocessor definition
matching ``${PREFIX}_COMPILER_${FEATURE_NAME_UPPER}`` is created in the
header file, and defined to either ``1`` or ``0``.

Additionally, some features call for additional defines, such as the
``cxx_final`` and ``cxx_override`` features. Rather than being used in
``#ifdef`` code, the ``final`` keyword should be abstracted by a symbol
which is defined to either ``final``, a compiler-specific equivalent, or
to empty.  That way, C++ code can be written to unconditionally use the
symbol, and compiler support determines what it is expanded to:

.. code-block:: c++

  struct Interface {
    virtual void Execute() = 0;
  };

  struct Concrete Foo_DECL_CXX_FINAL {
    void Execute() Foo_DECL_CXX_OVERRIDE;
  };

In this case, ``Foo_DECL_CXX_FINAL`` will expand to ``final`` if the
compiler supports the keyword, or to ``sealed`` if certain versions
of ``MSVC`` are used which do not support ``final``, but use ``sealed``
in the same position and with the same meaning, or to empty otherwise.

Such symbol definitions match the
pattern ``${PREFIX}_DECL_${FEATURE_NAME_UPPER}``.

In this use-case, the CMake code will wish to enable a particular language
standard if available from the compiler. The :prop_tgt:`CXX_STANDARD`
target property variable may be set to the desired language standard
for a particular target, and the :variable:`CMAKE_CXX_STANDARD` may be
set to influence all following targets:

.. code-block:: cmake

  write_compiler_detection_header(
    FILE "${CMAKE_CURRENT_BINARY_DIR}/foo_compiler_detection.h"
    PREFIX Foo
    COMPILERS GNU Clang MSVC
    FEATURES
      cxx_final cxx_override
  )

  # Includes foo_compiler_detection.h and uses the Foo_DECL_CXX_FINAL symbol
  # which will expand to 'final' if the compiler supports the requested
  # CXX_STANDARD.
  add_library(foo foo.cpp)
  set_property(TARGET foo PROPERTY CXX_STANDARD 11)

  # Includes foo_compiler_detection.h and uses the Foo_DECL_CXX_FINAL symbol
  # which will expand to 'final' if the compiler supports the feature,
  # even though CXX_STANDARD is not set explicitly. The requirement of
  # cxx_constexpr causes CMake to set CXX_STANDARD internally, which
  # affects the compile flags.
  add_library(foo_impl foo_impl.cpp)
  target_compile_features(foo_impl PRIVATE cxx_constexpr)

The ``write_compiler_detection_header`` function also creates compatibility
code for other features which have standard equivalents.  For example, the
``cxx_static_assert`` feature is emulated with a template and abstracted
via the ``${PREFIX}_STATIC_ASSERT`` and ``${PREFIX}_STATIC_ASSERT_MSG``
function-macros.

Conditional Compilation Options
===============================

Libraries may provide entirely different header files depending on
requested compiler features.

For example, a header at ``with_variadics/interface.h`` may contain:

.. code-block:: c++

  template<int I, int... Is>
  struct Interface;

  template<int I>
  struct Interface<I>
  {
    static int accumulate()
    {
      return I;
    }
  };

  template<int I, int... Is>
  struct Interface
  {
    static int accumulate()
    {
      return I + Interface<Is...>::accumulate();
    }
  };

while a header at ``no_variadics/interface.h`` may contain:

.. code-block:: c++

  template<int I1, int I2 = 0, int I3 = 0, int I4 = 0>
  struct Interface
  {
    static int accumulate() { return I1 + I2 + I3 + I4; }
  };

It would be possible to write a abstraction ``interface.h`` header
containing something like:

.. code-block:: c++

  #include "foo_compiler_detection.h"
  #if Foo_COMPILER_CXX_VARIADIC_TEMPLATES
  #include "with_variadics/interface.h"
  #else
  #include "no_variadics/interface.h"
  #endif

However this could be unmaintainable if there are many files to
abstract. What is needed is to use alternative include directories
depending on the compiler capabilities.

CMake provides a ``HAVE_COMPILE_FEATURE``
:manual:`generator expression <cmake-generator-expressions(7)>` to implement
such conditions.  This may be used with the
:command:`target_include_directories`, or :command:`target_link_libraries`
to set the appropriate :manual:`buildsystem <cmake-buildsystem(7)>`
properties:

.. code-block:: cmake

  add_library(with_variadics INTERFACE)
  target_include_directories(with_variadics
    INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/with_variadics")

  add_library(no_variadics INTERFACE)
  target_include_directories(no_variadics
    INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/no_variadics")

  add_library(foo INTERFACE)
  target_link_libraries(foo
    INTERFACE
      $<$<HAVE_COMPILER_FEATURE:cxx_variadic_templates>:have_variadics>
      $<$<NOT:$<HAVE_COMPILER_FEATURE:cxx_variadic_templates>>:no_variadics>)

Consuming code then simply links to the ``foo`` target as usual and uses
the feature-appropriate include directory

.. code-block:: cmake

  add_executable(consumer_with consumer_with.cpp)
  target_link_libraries(consumer_with foo)
  set_property(TARGET consumer_with CXX_STANDARD 11)

  add_executable(consumer_no consumer_no.cpp)
  target_link_libraries(consumer_no foo)
