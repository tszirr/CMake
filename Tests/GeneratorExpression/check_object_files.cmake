
if (NOT EXISTS ${OBJLIB_LISTFILE})
  message(SEND_ERROR "Object listing file \"${OBJLIB_LISTFILE}\" not found!")
endif()

file(STRINGS ${OBJLIB_LISTFILE} objlib_files)

list(LENGTH objlib_files num_objectfiles)
if (NOT EXPECTED_NUM_OBJECTFILES EQUAL num_objectfiles)
  message(SEND_ERROR "Unexpected number of entries in object list file (${num_objectfiles} instead of ${EXPECTED_NUM_OBJECTFILES})")
endif()

foreach(objlib_file ${objlib_files})
  if (NOT EXISTS ${objlib_file})
    message(SEND_ERROR "File \"${objlib_file}\" does not exist!")
  endif()
endforeach()
