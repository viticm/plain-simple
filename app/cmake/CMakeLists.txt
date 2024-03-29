# Copyright 2017 Viticm. All rights reserved.
#
# Licensed under the MIT License(the "License");
# you may not use this file except in compliance with the License.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
cmake_minimum_required(VERSION 2.8.12)

#set_compiler_flags_for_external_libraries()
#restore_compiler_flags()

option(pf_use_shared "Use plain framework with share library." ON)
option(pf_build_misc "Build all misc library for app" ON)
option(pf_build_luasql_mysql "Build luasql for mysql library(need installed mysql client library) " OFF)

# Include helper functions and macros used by Google Test.
config_compiler_and_linker()
string(REPLACE "-W4" "-W3" cxx_default "${cxx_default}")
string(REPLACE "-Wshadow" "" cxx_default "${cxx_default}")
string(REPLACE "-Wextra" "" cxx_default "${cxx_default}")

# This is the directory into which the executables are built.
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${gtest_incdir}
                    ${gtest_hack_incdir}
                    ${root_dir}/app/include/
                    ${CMAKE_CURRENT_LIST_DIR})

# Common libraries for tests.
if(NOT MSVC)
  find_package(Threads)
endif()
set(COMMON_LIBS "pf_core;${CMAKE_THREAD_LIBS_INIT}")

if (MSVC AND pf_use_shared)
  set(cxx_base_flags "${cxx_base_flags} -DPF_BUILD_AS_DLL")
endif()

# Plain Framework core flags.
set(cxx_base_flags "${cxx_base_flags} -DPF_OPEN_EPOLL")

set(CMAKE_CXX_STANDARD 11)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif()

# Generate a rule to build a unit test executable ${test_name} with
# source file ${source}.  For details of additional arguments, see
# mathfu_configure_flags().
function(test_executable test_name source)
  cxx_executable_with_flags(${test_name} "${cxx_base_flags} ${cxx_default}" "${COMMON_LIBS}"
    ${source} ${PLAINFRAMEWORK_HEADERS})
  plainframework_configure_flags(${test_name} ${ARGN})
  plainframework_enable_warnings(${test_name})
  set_target_properties(${test_name} PROPERTIES DEBUG_POSTFIX "d")
  # Find shared libraries in current directory.
  if (NOT MSVC)
    set_target_properties(${test_name} PROPERTIES LINK_FLAGS "-Wl,-rpath,./")
  endif()
endfunction()

# Generate a rule to build unit test executables.
function(test_executables test_name source)
  # Default build options for the target architecture.
  test_executable(${test_name} "${source}")
  MESSAGE(${source})
endfunction()

# Add lua library.
function (cxx_lua_library name flags libs)
  cxx_shared_library(${name} "${cxx_base_flags} ${cxx_default} ${flags}" ${ARGN})
  set_target_properties(${name} PROPERTIES
    PREFIX ""
    DEBUG_POSTFIX ""
    LIBRARY_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/${lua_output_path}"
    RUNTIME_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/${lua_output_path}"
    ARCHIVE_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/${lua_output_path}"
    PDB_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/${lua_output_path}"
  )
  target_link_libraries(${name} PUBLIC "${lua_libs};${libs}")
  # Find shared libraries in current directory.
  if (NOT MSVC)
    set_target_properties(${name} PROPERTIES LINK_FLAGS "-Wl,-rpath,./")
  endif()
endfunction()

# Build lua and other libraries.
if (pf_build_misc)

  if (NOT lua_dir)
    message(WARNING "can't found the lua directory(use system include)")
  else()
    include_directories(${lua_dir})
  endif()

  # Lua libraries output directory.
  if (NOT lua_output_path)
    if (plain_simple_only)
      set(lua_output_path "public/luaclib/")
    else()
      set(lua_output_path "luaclib/")
    endif()
  endif()

  set(lua_misc_dir "${root_dir}/app/misc/lualib-src/")
  if (MSVC)
    set(lua_libs "pf_core;pf_plugin_lua")
    set(lua_flags "-DLUA_BUILD_AS_DLL -wd4996 -wd4267 -wd4133 -wd4244")
  endif()

  cxx_lua_library(gbk "${lua_flags}" "" ${lua_misc_dir}/lua-gbk/lgbk.c)
  cxx_lua_library(pb "${lua_flags}" "" ${lua_misc_dir}/lua-protobuf/pb.c)
  cxx_lua_library(lfs "${lua_flags}" "" ${lua_misc_dir}/luafilesystem/src/lfs.c)
  set(lua_socket_flags "${lua_flags} -DLUASOCKET_DEBUG")
  if (MSVC)
    #set(lua_socket_flags "${lua_flags} -DLUASOCKET_API=__declspec(dllexport)")
    #set(lua_socket_flags "${lua_flags} ${lua_socket_flags} -DMIME_API=__declspec(dllexport)")
  else()
    #set(lua_socket_flags "-DLUASOCKET_API=__attribute__((visibility(\\\"default\\\")))")
    #set(lua_socket_flags "${lua_socket_flags} -DUNIX_API=__attribute__((visibility(\\\"default\\\")))")
    #set(lua_socket_flags "${lua_socket_flags} -DMIME_API=__attribute__((visibility(\\\"default\\\")))")
  endif()
  set(lua_socket_core_sources
    ${lua_misc_dir}/luasocket/src/luasocket.c
    ${lua_misc_dir}/luasocket/src/timeout.c
    ${lua_misc_dir}/luasocket/src/buffer.c
    ${lua_misc_dir}/luasocket/src/io.c
    ${lua_misc_dir}/luasocket/src/auxiliar.c
    ${lua_misc_dir}/luasocket/src/options.c
    ${lua_misc_dir}/luasocket/src/inet.c
    ${lua_misc_dir}/luasocket/src/except.c
    ${lua_misc_dir}/luasocket/src/select.c
    ${lua_misc_dir}/luasocket/src/tcp.c
    ${lua_misc_dir}/luasocket/src/udp.c
    ${lua_misc_dir}/luasocket/src/compat.c
  )
  if (MSVC)
    cxx_lua_library(socket "${lua_socket_flags}" "" ${lua_socket_core_sources} ${lua_misc_dir}/luasocket/src/wsocket.c)
  else()
    cxx_lua_library(socket "${lua_socket_flags}" "" ${lua_socket_core_sources} ${lua_misc_dir}/luasocket/src/usocket.c)
  endif()
  set(lua_socket_mime_sources
    ${lua_misc_dir}/luasocket/src/mime.c
    ${lua_misc_dir}/luasocket/src/compat.c
  )
  cxx_lua_library(mime "${lua_socket_flags}" "" ${lua_socket_mime_sources})
  if (NOT MSVC)
    set(lua_socket_unix_sources
      ${lua_misc_dir}/luasocket/src/buffer.c
      ${lua_misc_dir}/luasocket/src/auxiliar.c
      ${lua_misc_dir}/luasocket/src/options.c
      ${lua_misc_dir}/luasocket/src/timeout.c
      ${lua_misc_dir}/luasocket/src/io.c
      ${lua_misc_dir}/luasocket/src/usocket.c
      ${lua_misc_dir}/luasocket/src/unix.c
    )
    #cxx_lua_library(socket_unix "${lua_socket_flags}" ${lua_socket_unix_sources})
    set(lua_socket_serial_sources
      ${lua_misc_dir}/luasocket/src/buffer.c
      ${lua_misc_dir}/luasocket/src/auxiliar.c
      ${lua_misc_dir}/luasocket/src/options.c
      ${lua_misc_dir}/luasocket/src/timeout.c
      ${lua_misc_dir}/luasocket/src/io.c
      ${lua_misc_dir}/luasocket/src/usocket.c
      ${lua_misc_dir}/luasocket/src/serial.c
    )
    #cxx_lua_library(socket_serial "${lua_socket_flags}" ${lua_socket_serial_sources})
  endif()
  if (pf_build_luasql_mysql)

    # The msyql dir.
    if (NOT mysql_dir)
      set(mysql_dir ${root_dir}/dependencies/mysql)
    endif()
    if (EXISTS ${mysql_dir})
      include_directories(${root_dir}/dependencies/mysql/include)
      link_directories(${root_dir}/dependencies/mysql/lib)
    elseif (MSVC)
      message(SEND_ERROR "mysql directory not found.")
    else()
      # Unix can install mysql devel package.
      message(WARNING "mysql directory will use by system")
      include_directories(/usr/include/mysql)
      link_directories(/usr/lib64/mysql)
    endif()
    set(luasql_mysql_sources
      ${lua_misc_dir}/luasql/src/ls_mysql.c
      ${lua_misc_dir}/luasql/src/luasql.c
    )
    if (MSVC)
      set(luasql_flags "${lua_flags} -DLUASQL_API=__declspec(dllexport)")
    else()
      set(luasql_flags "${lua_flags}")
    endif()
    cxx_lua_library(luasql_mysql "${luasql_flags}" "mysqlclient" ${luasql_mysql_sources})
  endif()
endif()

file(GLOB_RECURSE APP_SOURCES "../src/*.cc")

test_executables(app "${APP_SOURCES}")
