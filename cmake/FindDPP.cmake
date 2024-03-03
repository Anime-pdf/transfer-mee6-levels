if(NOT CMAKE_CROSSCOMPILING)
    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_DPP libdpp)
endif()

function(set_extra_dirs_lib VARIABLE NAME)
    set("PATHS_${VARIABLE}_LIBDIR" PARENT_SCOPE)
    set("HINTS_${VARIABLE}_LIBDIR" PARENT_SCOPE)
    if(PREFER_BUNDLED_LIBS)
        set(TYPE HINTS)
    else()
        set(TYPE PATHS)
    endif()
    if(TARGET_BITS AND TARGET_OS)
        set(DIR "libs/${NAME}/${LIB_DIR}")
        set("${TYPE}_${VARIABLE}_LIBDIR" "${DIR}" PARENT_SCOPE)
        set("EXTRA_${VARIABLE}_LIBDIR" "${DIR}" PARENT_SCOPE)
    endif()
endfunction()

function(set_extra_dirs_include VARIABLE NAME LIBRARY)
    set("PATHS_${VARIABLE}_INCLUDEDIR" PARENT_SCOPE)
    set("HINTS_${VARIABLE}_INCLUDEDIR" PARENT_SCOPE)
    is_bundled(IS_BUNDLED "${LIBRARY}")
    if(IS_BUNDLED)
        set(TMP_TARGET_OS ${TARGET_OS})
        if(CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
            set(TMP_TARGET_OS webasm)
        endif()
        set("HINTS_${VARIABLE}_INCLUDEDIR" "libs/${NAME}/include" "libs/${NAME}/include/${TMP_TARGET_OS}" PARENT_SCOPE)
    endif()
endfunction()

function(is_bundled VARIABLE PATH)
    if(PATH)
        string(FIND "${PATH}" "${PROJECT_SOURCE_DIR}" LOCAL_PATH_POS)
        if(LOCAL_PATH_POS EQUAL 0 AND TARGET_BITS AND TARGET_OS)
            set("${VARIABLE}" ON PARENT_SCOPE)
        else()
            set("${VARIABLE}" OFF PARENT_SCOPE)
        endif()
    else()
        set("${VARIABLE}" OFF PARENT_SCOPE)
    endif()
endfunction()

message(STATUS "Searching for DPP_LIBRARY")
set_extra_dirs_lib(DPP DPP)
find_library(DPP_LIBRARY
        NAMES dpp libdpp
        HINTS ${PROJECT_SOURCE_DIR}/libs/DPP/windows/lib64 ${PROJECT_SOURCE_DIR}/libs/DPP/linux/lib64
        PATHS ${PROJECT_SOURCE_DIR}/libs/DPP/windows/lib64 ${PROJECT_SOURCE_DIR}/libs/DPP/linux/lib64
        ${CROSSCOMPILING_NO_CMAKE_SYSTEM_PATH}
)

if(DPP_LIBRARY)
    message(STATUS "DPP_LIBRARY found: ${DPP_LIBRARY}")
else()
    message(STATUS "DPP_LIBRARY not found.")
endif()


message(STATUS "Searching for DPP_INCLUDEDIR")
set_extra_dirs_include(DPP DPP "${DPP_LIBRARY}")
find_path(DPP_INCLUDEDIR
        NAMES dpp/version.h
        HINTS ${PROJECT_SOURCE_DIR}/libs/DPP/include
        PATHS ${PROJECT_SOURCE_DIR}/libs/DPP/include
        ${CROSSCOMPILING_NO_CMAKE_SYSTEM_PATH}
)

if(DPP_INCLUDEDIR)
    message(STATUS "DPP_INCLUDEDIR found: ${DPP_INCLUDEDIR}")
else()
    message(STATUS "DPP_INCLUDEDIR not found.")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DPP DEFAULT_MSG DPP_LIBRARY DPP_INCLUDEDIR)

mark_as_advanced(DPP_LIBRARY DPP_INCLUDEDIR)

if(DPP_FOUND)
    set(DPP_LIBRARIES ${DPP_LIBRARY})
    set(DPP_INCLUDE_DIRS ${DPP_INCLUDEDIR})

    is_bundled(DPP_BUNDLED "${DPP_LIBRARY}")
    set(DPP_COPY_FILES)
    if(DPP_BUNDLED)
        if(TARGET_OS STREQUAL "windows")
            set(DPP_COPY_FILES
                    "${EXTRA_DPP_LIBDIR}/dpp.dll"
                    "${EXTRA_DPP_LIBDIR}/libssl-1_1-x64.dll"
                    "${EXTRA_DPP_LIBDIR}/libsodium.dll"
                    "${EXTRA_DPP_LIBDIR}/opus.dll"
                    "${EXTRA_DPP_LIBDIR}/libcrypto-1_1-x64.dll")
        elseif(TARGET_OS STREQUAL "linux")
            set(DPP_COPY_FILES "${EXTRA_DPP_LIBDIR}/libdpp.so")
        endif()
    endif()
endif()