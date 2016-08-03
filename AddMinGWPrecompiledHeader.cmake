macro(ADD_MINGW_PRECOMPILED_HEADER PrecompiledHeader ProjectName)
  if(MINGW)
    get_directory_property(DirIncs INCLUDE_DIRECTORIES)

    find_path(${ProjectName}_PrecompiledPath NAMES ${PrecompiledHeader} PATHS ${DirIncs})
    set(PREC_INPUT "${${ProjectName}_PrecompiledPath}/${PrecompiledHeader}")

    get_filename_component(${ProjectName}_PrecompiledBasename ${PREC_INPUT} NAME)
    
    set(PREC_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${${ProjectName}_PrecompiledBasename}.gch")

    set(PREC_FLAGS
      -g
      -c "${PREC_INPUT}" 
      -o "${PREC_OUTPUT}"
      -m${BITNESS}
      -std=gnu++11
    )

    foreach(include_dir ${DirIncs})
      list(APPEND PREC_FLAGS -I"${include_dir}")
    endforeach()

    get_directory_property(DirDefs COMPILE_DEFINITIONS)
    foreach(dir_def ${DirDefs})
      list(APPEND PREC_FLAGS -D"${dir_def}")
    endforeach()

    add_custom_command(OUTPUT "${PREC_OUTPUT}"
      COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}} ${PREC_FLAGS}
      DEPENDS "${PREC_INPUT}"
      IMPLICIT_DEPENDS CXX "${PREC_INPUT}")

    add_custom_target(${ProjectName}_generate_precompiled DEPENDS "${PREC_OUTPUT}")
  
    add_dependencies(${ProjectName} ${ProjectName}_generate_precompiled)

    get_target_property(C_FLAGS ${ProjectName} COMPILE_FLAGS)
    set(C_FLAGS "${C_FLAGS} -Winvalid-pch -include ${PrecompiledHeader}")
    set_target_properties(${ProjectName} PROPERTIES COMPILE_FLAGS ${C_FLAGS})

  endif(MINGW)
endmacro(ADD_MINGW_PRECOMPILED_HEADER)