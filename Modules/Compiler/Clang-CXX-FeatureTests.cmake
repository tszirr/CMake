
# Reference: http://clang.llvm.org/cxx_status.html
# http://clang.llvm.org/docs/LanguageExtensions.html

set(testable_features
  cxx_reference_qualified_functions
  cxx_decltype_incomplete_return_types
  cxx_inheriting_constructors
  cxx_alignas
  cxx_attributes
  cxx_thread_local
  cxx_delegating_constructors
  cxx_nonstatic_member_init
  cxx_noexcept
  cxx_alias_templates
  cxx_user_literals
  cxx_constexpr
  cxx_nullptr
  cxx_range_for
  cxx_unrestricted_unions
  cxx_explicit_conversions
  cxx_lambdas
  cxx_raw_string_literals
  cxx_local_type_template_args
  cxx_variadic_templates
  cxx_auto_type
  cxx_strong_enums
  cxx_defaulted_functions
  cxx_deleted_functions
  cxx_unicode_literals
  cxx_generalized_initializers
  cxx_static_assert
  cxx_decltype
  cxx_rvalue_references
  cxx_default_function_template_args
)
foreach(feature ${testable_features})
  set(_cmake_feature_test_${feature} "__has_feature(${feature})")
endforeach()

unset(testable_features)

set(_oldestSupported "((__clang_major__ * 100) + __clang_minor__) >= 304")

set(_cmake_feature_test_gnu_cxx_typeof "${_oldestSupported} && !defined(__STRICT_ANSI__)")
set(_cmake_feature_test_cxx_alignof "__has_feature(cxx_alignas)")
set(_cmake_feature_test_cxx_final "__has_feature(cxx_override_control)")
set(_cmake_feature_test_cxx_override "__has_feature(cxx_override_control)")
set(_cmake_feature_test_cxx_uniform_initialization "__has_feature(cxx_generalized_initializers)")
set(_cmake_feature_test_cxx_auto_function "__has_feature(cxx_auto_type)")

# TODO: Should be supported by Clang 3.1
set(_cmake_feature_test_cxx_enum_forward_declarations "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_sizeof_member "${_oldestSupported} && __cplusplus >= 201103L")
# TODO: Should be supported by Clang 2.9
set(_cmake_feature_test_cxx_extended_friend_declarations "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_inline_namespaces "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_right_angle_brackets "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_long_long_type "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_extern_templates "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_variadic_macros "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_func_identifier "${_oldestSupported} && __cplusplus >= 201103L")

# TODO: Should be supported forever?
set(_cmake_feature_test_cxx_template_template_parameters "${_oldestSupported} && __cplusplus >= 199711L")
set(_cmake_feature_test_gnu_cxx_typeof "${_oldestSupported} && !defined(__STRICT_ANSI__)")

set(_oldestSupported)
