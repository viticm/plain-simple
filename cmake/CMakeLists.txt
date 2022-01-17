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

set(PROJECT_NAME PlainFrameworkSimple)
set(PF_SIMPLE_VERSION 1.0.0)
set(PROJECT_DESC "Plain framework simple")

if (CMAKE_VERSION VERSION_LESS 3.0)
  project(PlainFrameworkSimple CXX C)
else()
  cmake_policy(SET CMP0048 NEW)
  cmake_policy(SET CMP0037 NEW)
  project(PlainFrameworkSimple VERSION ${PF_SIMPLE_VERSION} LANGUAGES CXX C)
endif()

# Build plainframework.
option(plainframework_build "Build plain framework" ON)

# Options that control the build configuration.
# To configure PlainFramework flags per build target, see the
# plainframework_configure_flags() function.
option(plainframework_build_tests "Build PlainFramework unit tests." ON)

# Call fplutil to get locations of dependencies and set common build settings.
include("inc/internal_utils.cmake")
include("inc/common.cmake")

# The built output paths.
if (NOT has_output_path)

  # This is the directory into which the executables are built.
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${root_dir}/bin)

  # This is the directory into which the librarys are built.
  set(LIBRARY_OUTPUT_PATH ${root_dir}/bin)

  # This flag is the project build as only.
  set(plain_simple_only 1)

  set(has_output_path 1)

endif()

# Set the plainframework not build app(build by self).
set(plainframework_no_app 1)

if (plainframework_build)
  add_subdir(${root_dir}/dependencies/plain/cmake plain plain-simple)
endif()

# Plian Framework use google test internal_utils(now will use self).
include("inc/internal_utils.cmake")

if(plainframework_build_tests)
  add_subdir(${root_dir}/app/cmake app plain-simple)
endif()
