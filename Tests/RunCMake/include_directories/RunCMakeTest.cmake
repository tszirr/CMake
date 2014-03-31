include(RunCMake)

run_cmake(NotFoundContent)
run_cmake(DebugIncludes)
run_cmake(TID-bad-target)
run_cmake(SourceDirectoryInInterface)
run_cmake(BinaryDirectoryInInterface)
run_cmake(RelativePathInInterface)
run_cmake(ImportedTarget)
run_cmake(RelativePathInGenex)
run_cmake(CMP0021)
run_cmake(install_config)
run_cmake(incomplete-genex)
run_cmake(export-NOWARN)

configure_file(
  "${RunCMake_SOURCE_DIR}/CMakeLists.txt"
  "${RunCMake_BINARY_DIR}/copy/CMakeLists.txt"
  COPYONLY
)
configure_file(
  "${RunCMake_SOURCE_DIR}/empty.cpp"
  "${RunCMake_BINARY_DIR}/copy/empty.cpp"
  COPYONLY
)
configure_file(
  "${RunCMake_SOURCE_DIR}/SourceDirectoryInInterface.cmake"
  "${RunCMake_BINARY_DIR}/copy/SourceDirectoryInInterface.cmake"
  COPYONLY
)
set(RunCMake_TEST_OPTIONS "-DCMAKE_INSTALL_PREFIX=${RunCMake_BINARY_DIR}/copy/SourceDirectoryInInterface/prefix")
set(RunCMake_TEST_FILE "${RunCMake_BINARY_DIR}/copy/SourceDirectoryInInterface")
set(RunCMake_TEST_SOURCE_DIR "${RunCMake_BINARY_DIR}/copy")
run_cmake(InstallInSrcDir)
unset(RunCMake_TEST_SOURCE_DIR)
unset(RunCMake_TEST_FILE)

set(RunCMake_TEST_OPTIONS "-DCMAKE_INSTALL_PREFIX=${RunCMake_BINARY_DIR}/InstallInBinDir-build/prefix")
set(RunCMake_TEST_BINARY_DIR "${RunCMake_BINARY_DIR}/InstallInBinDir-build")
set(RunCMake_TEST_FILE "${RunCMake_SOURCE_DIR}/BinaryDirectoryInInterface")
run_cmake(InstallInBinDir)
unset(RunCMake_TEST_BINARY_DIR)
unset(RunCMake_TEST_FILE)

set(RunCMake_TEST_OPTIONS "-DCMAKE_INSTALL_PREFIX=${RunCMake_BINARY_DIR}/prefix")
set(RunCMake_TEST_BINARY_DIR "${RunCMake_BINARY_DIR}/prefix/BinInInstallPrefix-build")
set(RunCMake_TEST_FILE "${RunCMake_SOURCE_DIR}/BinaryDirectoryInInterface")
run_cmake(BinInInstallPrefix)
unset(RunCMake_TEST_BINARY_DIR)
unset(RunCMake_TEST_FILE)

configure_file(
  "${RunCMake_SOURCE_DIR}/CMakeLists.txt"
  "${RunCMake_BINARY_DIR}/prefix/src/CMakeLists.txt"
  COPYONLY
)
configure_file(
  "${RunCMake_SOURCE_DIR}/empty.cpp"
  "${RunCMake_BINARY_DIR}/prefix/src/empty.cpp"
  COPYONLY
)
configure_file(
  "${RunCMake_SOURCE_DIR}/SourceDirectoryInInterface.cmake"
  "${RunCMake_BINARY_DIR}/prefix/src/SourceDirectoryInInterface.cmake"
  COPYONLY
)
set(RunCMake_TEST_FILE "${RunCMake_BINARY_DIR}/prefix/src/SourceDirectoryInInterface")
set(RunCMake_TEST_SOURCE_DIR "${RunCMake_BINARY_DIR}/prefix/src")
run_cmake(SrcInInstallPrefix)
unset(RunCMake_TEST_SOURCE_DIR)
unset(RunCMake_TEST_FILE)

set(RunCMake_TEST_OPTIONS "-DCMAKE_INSTALL_PREFIX=${RunCMake_BINARY_DIR}/InstallToPrefixInBinDir-build/prefix")
run_cmake(InstallToPrefixInBinDir)
