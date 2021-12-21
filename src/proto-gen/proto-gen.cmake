if (MSVC)
    set(PROTOC_EXE ${protobuf_BINARY_DIR}/$<CONFIG>/protoc${CMAKE_EXECUTABLE_SUFFIX})
    set(GRPC_CPP_PLUGIN_EXE ${grpc_BINARY_DIR}/$<CONFIG>/grpc_cpp_plugin${CMAKE_EXECUTABLE_SUFFIX})
else ()
    set(PROTOC_EXE ${protobuf_BINARY_DIR}/protoc${CMAKE_EXECUTABLE_SUFFIX})
    set(GRPC_CPP_PLUGIN_EXE ${grpc_BINARY_DIR}/grpc_cpp_plugin${CMAKE_EXECUTABLE_SUFFIX})
endif ()

message(STATUS "Using protoc at ${PROTOC_EXE}")
message(STATUS "Using grpc_cpp_plugin at ${GRPC_CPP_PLUGIN_EXE}")

function(add_proto_source name)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/${name}.pb.cc
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/proto/${name}.proto
                ${PROTOC_EXE}
        COMMAND ${PROTOC_EXE}
                --cpp_out ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen -I${CMAKE_CURRENT_SOURCE_DIR}/proto
                ${CMAKE_CURRENT_SOURCE_DIR}/proto/${name}.proto
    )
endfunction(add_proto_source name)

function(add_proto_service name)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/${name}.grpc.pb.cc
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/proto/${name}.proto
                ${PROTOC_EXE}
                ${GRPC_CPP_PLUGIN_EXE}
        COMMAND ${PROTOC_EXE}
                --grpc_out ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen -I${CMAKE_CURRENT_SOURCE_DIR}/proto
                --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_EXE}
                ${CMAKE_CURRENT_SOURCE_DIR}/proto/${name}.proto
    )
endfunction(add_proto_service name)


add_proto_source(common)
add_proto_source(schema)
add_proto_source(milvus)
add_proto_service(milvus)

set(milvus_sdk_proto_files
    ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/common.pb.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/schema.pb.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/milvus.pb.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/proto-gen/milvus.grpc.pb.cc
)

