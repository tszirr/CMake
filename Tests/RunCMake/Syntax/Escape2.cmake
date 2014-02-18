cmake_policy(SET CMP0052 NEW)

macro (escape str)
  message("${str}")
endmacro ()

escape("\\")
