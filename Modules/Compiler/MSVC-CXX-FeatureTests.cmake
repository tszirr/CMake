
set(_cmake_compiler_test_macro "defined(_MSC_VER)")

set(_cmake_feature_test_cxx_delegating_constructors "_MSC_VER >= 1800")
set(_cmake_feature_test_cxx_variadic_templates "_MSC_VER >= 1800")

set(_cmake_feature_test_msvcxx_sealed "_MSC_VER >= 1400")

set(_cmake_feature_test_cxx_static_assert "_MSC_VER >= 1600")

set(_cmake_feature_test_cxx_final "_MSC_VER >= 1700")
set(_cmake_feature_test_cxx_override "_MSC_VER >= 1400")

set(_cmake_symbol_alternative_cxx_final "sealed")
set(_cmake_symbol_alternative_test_cxx_final "_MSC_VER >= 1400")
