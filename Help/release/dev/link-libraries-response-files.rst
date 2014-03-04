link-libraries-response-files
-----------------------------

* The Makefile generators learned to use response files with
  GNU tools on Windows to pass the list of link directories
  and libraries when linking executables and shared libraries.
  This matches the approach already used for passing include
  directories to the compiler and object files to the linker
  or archiver.  It allows very long lists of libraries.
