include(Platform/Linux)
set(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "")
# RPath is useless on Android, because we can't determine the installation
# location ahead of time.
set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "")

# Gui executables on Android are loaded as plugins by the java process,
# so build them as PIC by default.  The packaging system accepts only files
# which have a .so suffix, so set the CMAKE_EXECUTABLE_SUFFIX to that.
# Non-gui native executables are also permitted on Android.  Users wishing
# to create such executables may use something like
#   set_property(TARGET MyConsoleExe PROPERTY SUFFIX "")
#   set_property(TARGET MyConsoleExe PROPERTY POSITION_INDEPENDENT_CODE OFF)
# to clear the suffix and -fPIE flag, if desired.
# This possibly does not work with older Android versions:
#  https://groups.google.com/forum/#!msg/android-security-discuss/B9BEdc_faRw/iMjpQqXMA1YJ
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_EXECUTABLE_SUFFIX .so)
