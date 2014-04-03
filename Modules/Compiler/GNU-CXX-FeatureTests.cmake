
set(_oldestSupported "(__GNUC__ * 100 + __GNUC_MINOR__) >= 408")
# TODO: Should be supported by GNU 4.7
set(GNU47_CXX11 "${_oldestSupported} && __cplusplus >= 201103L")
set(_cmake_feature_test_cxx_delegating_constructors "${GNU47_CXX11}")
set(_oldestSupported)
