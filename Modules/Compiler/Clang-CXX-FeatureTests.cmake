
set(testable_features
  cxx_delegating_constructors
  cxx_variadic_templates
  cxx_constexpr
  cxx_static_assert
)
foreach(feature ${testable_features})
  set(_cmake_feature_test_${feature} "__has_extension(${feature})")
endforeach()

unset(testable_features)

set(_cmake_feature_test_gnuxx_typeof "!defined(__STRICT_ANSI__)")
set(_cmake_feature_test_cxx_final "__has_extension(cxx_override_control)")
set(_cmake_feature_test_cxx_override "__has_extension(cxx_override_control)")
set(_cmake_feature_test_cxx_binary_literals "1")
