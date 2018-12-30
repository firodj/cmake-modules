macro(ADD_MINGW_PRECOMPILED_HEADER ProjectName PrecompiledHeader PrecompiledFlags)
  if(NOT MSVC)

    if (MINGW OR CMAKE_COMPILER_IS_GNUCXX)
      set(GNUC TRUE)
    elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      set(CLANG TRUE)
    endif()

    get_directory_property(DirIncs INCLUDE_DIRECTORIES)

    find_path(${ProjectName}_PrecompiledPath NAMES ${PrecompiledHeader} PATHS ${DirIncs})
    set(PREC_INPUT "${${ProjectName}_PrecompiledPath}/${PrecompiledHeader}")

    get_filename_component(${ProjectName}_PrecompiledBasename ${PREC_INPUT} NAME)

    set(PREC_FLAGS ${PrecompiledFlags})
    separate_arguments(PREC_FLAGS)

    if (GNUC)
      set(PREC_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${${ProjectName}_PrecompiledBasename}.gch")
      set(PREC_FLAGS ${PREC_FLAGS}
        -c "${PREC_INPUT}" 
        -o "${PREC_OUTPUT}"
      )
    elseif(CLANG)
      set(PREC_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${${ProjectName}_PrecompiledBasename}.pch")
      set(PREC_FLAGS ${PREC_FLAGS}
        -x c++-header
        -c "${PREC_INPUT}" 
        -o "${PREC_OUTPUT}"
      )
    endif(GNUC)

    foreach(include_dir ${DirIncs})
      list(APPEND PREC_FLAGS -I"${include_dir}")
    endforeach()

    get_directory_property(DirDefs COMPILE_DEFINITIONS)
    foreach(dir_def ${DirDefs})
      list(APPEND PREC_FLAGS -D"${dir_def}")
    endforeach()

    message(STATUS "PREC_FLAGS: ${PREC_FLAGS}")
    add_custom_command(OUTPUT "${PREC_OUTPUT}"
      COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}} ${PREC_FLAGS}
      DEPENDS "${PREC_INPUT}"
      IMPLICIT_DEPENDS CXX "${PREC_INPUT}")

    add_custom_target(${ProjectName}_generate_precompiled DEPENDS "${PREC_OUTPUT}")
  
    add_dependencies(${ProjectName} ${ProjectName}_generate_precompiled)

    if (GNUC)
      set(PCH_FLAGS "-Winvalid-pch -include ${PrecompiledHeader}")
    elseif (CLANG)
      set(PCH_FLAGS -include-pch ${PREC_OUTPUT})
    endif()

    message(STATUS "PCH_FLAGS: ${PCH_FLAGS}")
    # get_target_property(CXX_FLAGS ${ProjectName} COMPILE_FLAGS)
    # set(CXX_FLAGS "${CXX_FLAGS} ${${ProjectName}_PCH_FLAGS}")
    # set_target_properties(${ProjectName} PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
    target_compile_options(${ProjectName} PRIVATE
      $<$<COMPILE_LANGUAGE:CXX>:${PCH_FLAGS}>)
  endif(NOT MSVC)
endmacro(ADD_MINGW_PRECOMPILED_HEADER)