# Licensed to the LF AI & Data foundation under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


include(FetchContent)
set(FETCHCONTENT_QUIET OFF)

# Ensure that a default make is set
if ("${MAKE}" STREQUAL "")
    find_program(MAKE make)
endif ()

if (NOT DEFINED MAKE_BUILD_ARGS)
    set(MAKE_BUILD_ARGS "-j8")
endif ()
message(STATUS "Third Party MAKE_BUILD_ARGS = ${MAKE_BUILD_ARGS}")

# ----------------------------------------------------------------------
# Find pthreads

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# ----------------------------------------------------------------------
# External source default urls

if (DEFINED ENV{MILVUS_GRPC_REPO})
    set(GRPC_REPO "$ENV{MILVUS_GRPC_REPO}")
else ()
    set(GRPC_REPO "https://github.com/grpc/grpc")
endif ()

if (DEFINED ENV{MILVUS_GRPC_RELEASE_TAG})
    set(GRPC_RELEASE_TAG "$ENV{MILVUS_GRPC_RELEASE_TAG}")
else ()
    set(GRPC_RELEASE_TAG "v1.51.1")
endif ()

if (DEFINED ENV{MILVUS_GTEST_URL})
    set(GTEST_SOURCE_URL "$ENV{MILVUS_GTEST_URL}")
else ()
    set(GTEST_SOURCE_URL "https://github.com/google/googletest/archive/release-1.12.1.tar.gz")
endif ()

if (DEFINED ENV{MILVUS_NLOHMANN_JSON_URL})
    set(NLOHMANN_JSON_SOURCE_URL "${ENV{MILVUS_NLOHMANN_JSON_URL}")
else ()
    set(NLOHMANN_JSON_SOURCE_URL "https://github.com/nlohmann/json/archive/refs/tags/v3.11.2.tar.gz")
endif ()

# grpc
FetchContent_Declare(
    grpc
    GIT_REPOSITORY ${GRPC_REPO}
    GIT_TAG ${GRPC_RELEASE_TAG}
)

FetchContent_Declare(
    googletest
    URL ${GTEST_SOURCE_URL}
)

FetchContent_Declare(
    nlohmann_json
    URL ${NLOHMANN_JSON_SOURCE_URL}
)

# enable grpc
if(NOT grpc_POPULATED)
    FetchContent_Populate(grpc)
    add_subdirectory(${grpc_SOURCE_DIR} ${grpc_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

# header only nlohmann json
if(NOT nlohmann_json_POPULATED)
    FetchContent_Populate(nlohmann_json)
    include_directories(${nlohmann_json_SOURCE_DIR}/include)
endif()
