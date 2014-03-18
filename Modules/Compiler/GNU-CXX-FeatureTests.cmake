
set(_oldestSupported "(__GNUC__ * 100 + __GNUC_MINOR__) >= 408")
# TODO: Should be supported by GNU 4.7
set(GNU47_CXX11 "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_delegating_constructors "${GNU47_CXX11}")
set(_cmake_feature_test_cxx_final "${GNU47_CXX11}")
# TODO: Should be supported by GNU 4.6
set(GNU46_CXX11 "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_constexpr "${GNU46_CXX11}")
# TODO: Should be supported by GNU 4.4
set(GNU44_CXX11 "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_variadic_templates "${GNU44_CXX11}")
# TODO: Should be supported by GNU 4.3
set(GNU43_CXX11 "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_static_assert "${GNU43_CXX11}")
set(_oldestSupported)
