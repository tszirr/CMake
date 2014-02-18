set(disallowed_chars
  a b c d e f g h i j l m   o p q   s   u v w x y z
  A B C D E F G H I J L M N O P Q R S T U V W X Y Z
  0 1 2 3 4 5 6 6 7 8 9)
set(testnum 0)

configure_file(
  "${RunCMake_SOURCE_DIR}/CMakeLists.txt"
  "${RunCMake_BINARY_DIR}/CMakeLists.txt"
  COPYONLY)

foreach (char IN LISTS disallowed_chars)
  configure_file(
    "${RunCMake_SOURCE_DIR}/char.cmake.in"
    "${RunCMake_BINARY_DIR}/${char}-${testnum}.cmake"
    @ONLY)
  configure_file(
    "${RunCMake_SOURCE_DIR}/char-stderr.txt.in"
    "${RunCMake_BINARY_DIR}/${char}-${testnum}-stderr.txt"
    @ONLY)
  configure_file(
    "${RunCMake_SOURCE_DIR}/char-result.txt"
    "${RunCMake_BINARY_DIR}/${char}-${testnum}-result.txt"
    COPYONLY)

  math(EXPR testnum "${testnum} + 1")
endforeach ()

function (run_tests)
  set(GENERATED_RUNCMAKE_TESTS TRUE)
  set(top_src "${RunCMake_BINARY_DIR}")
  set(top_bin "${RunCMake_BINARY_DIR}")

  set(testnum 0)
  foreach (char IN LISTS disallowed_chars)
    run_cmake("${char}-${testnum}")

    math(EXPR testnum "${testnum} + 1")
  endforeach ()
endfunction ()

run_tests()
