cmake_minimum_required(VERSION 3.12...3.27.4)

file(STRINGS src/version.h VERSION_LINE
        LIMIT_COUNT 1
        REGEX "^#define PROJECT_VERSION "
)

if(VERSION_LINE MATCHES "\"([0-9]+)\\.([0-9]+)\\.([0-9]+)\"")
    set(VERSION_MAJOR ${CMAKE_MATCH_1})
    set(VERSION_MINOR ${CMAKE_MATCH_2})
    set(VERSION_PATCH ${CMAKE_MATCH_3})
elseif(VERSION_LINE MATCHES "\"([0-9]+)\\.([0-9]+)\"")
    set(VERSION_MAJOR ${CMAKE_MATCH_1})
    set(VERSION_MINOR ${CMAKE_MATCH_2})
    set(VERSION_PATCH "0")
else()
    message(FATAL_ERROR "Couldn't parse version from version.h")
endif()

if(VERSION_PATCH STREQUAL "0")
    project(TransferMee6Levels VERSION ${VERSION_MAJOR}.${VERSION_MINOR})
else()
    project(TransferMee6Levels VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(TARGET_BITS "32")
else()
    set(TARGET_BITS "64")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(TARGET_OS "windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set(TARGET_OS "linux")
endif()

set(LIB_DIR "${TARGET_OS}/lib${TARGET_BITS}")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_subdirectory(libs/toml11)
find_package(DPP)

file(GLOB_RECURSE SOURCES src/*.cpp src/*.h)
add_executable(${PROJECT_NAME} main.cpp ${SOURCES})

target_link_libraries(${PROJECT_NAME} toml11)
target_include_directories(${PROJECT_NAME} PRIVATE libs/toml11)

if (DPP_FOUND)
    target_link_libraries(${PROJECT_NAME} ${DPP_LIBRARIES})
    target_include_directories(${PROJECT_NAME} PUBLIC ${DPP_INCLUDE_DIR})
    file(COPY ${DPP_COPY_FILES} DESTINATION .)
else()
    message(WARNING "Could not find DPP install. Building from source instead.")
    option(DPP_BUILD_TEST "" OFF)
    include(FetchContent)

    FetchContent_Declare(
            libdpp
            GIT_REPOSITORY https://github.com/brainboxdotcc/DPP.git
            GIT_TAG master)

    FetchContent_GetProperties(libdpp)
    if(NOT libdpp_POPULATED)
        FetchContent_Populate(libdpp)
        target_include_directories(${PROJECT_NAME} PUBLIC
                ${libdpp_SOURCE_DIR}/include
        )
        add_subdirectory(
                ${libdpp_SOURCE_DIR}
                ${libdpp_BINARY_DIR}
                EXCLUDE_FROM_ALL)
    endif()

    target_link_libraries(${PROJECT_NAME} dpp)
endif()

function(show_dependency_status OUTPUT_NAME NAME)
    if(${NAME}_FOUND)
        if(${NAME}_BUNDLED)
            message(STATUS " * ${OUTPUT_NAME} not found (using bundled version)")
        else()
            message(STATUS " * ${OUTPUT_NAME} found")
        endif()
    else()
        message(STATUS " * ${OUTPUT_NAME} not found")
    endif()
endfunction()

message(STATUS "******** ${CMAKE_PROJECT_NAME} ********")
message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "Target OS: ${TARGET_OS} ${TARGET_BITS}-bit ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

message(STATUS "Dependencies:")
show_dependency_status("DPP" DPP)