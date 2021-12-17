// Licensed to the LF AI & Data foundation under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once

#include <grpc/grpc.h>
#include <grpcpp/channel.h>
#include <grpcpp/client_context.h>
#include <grpcpp/create_channel.h>
#include <grpcpp/security/credentials.h>

#include <memory>
#include <string>

#include "Status.h"
#include "common.pb.h"
#include "milvus.grpc.pb.h"
#include "milvus.pb.h"
#include "schema.pb.h"

namespace milvus {
class MilvusConnection {
 public:
    MilvusConnection() = default;

    virtual ~MilvusConnection();

    Status
    Connect(const std::string& uri);

    Status
    Disconnect();

    Status
    CreateCollection(const proto::milvus::CreateCollectionRequest& request, proto::common::Status& response);

    Status
    DropCollection(const proto::milvus::DropCollectionRequest& request, proto::common::Status& response);

    Status
    HasCollection(const proto::milvus::HasCollectionRequest& request, proto::milvus::BoolResponse& response);

    Status
    LoadCollection(const proto::milvus::LoadCollectionRequest& request, proto::common::Status& response);

    Status
    ReleaseCollection(const proto::milvus::ReleaseCollectionRequest& request, proto::common::Status& response);

    Status
    DescribeCollection(const proto::milvus::DescribeCollectionRequest& request,
                       proto::milvus::DescribeCollectionResponse& response);

    Status
    GetCollectionStats(const proto::milvus::GetCollectionStatisticsRequest& request,
                       proto::milvus::GetCollectionStatisticsResponse& response);

    Status
    ShowCollections(const proto::milvus::ShowCollectionsRequest& request,
                    proto::milvus::ShowCollectionsResponse& response);

    Status
    CreatePartition(const proto::milvus::CreatePartitionRequest& request, proto::common::Status& response);

    Status
    DropPartition(const proto::milvus::DropPartitionRequest& request, proto::common::Status& response);

    Status
    HasPartition(const proto::milvus::HasPartitionRequest& request, proto::milvus::BoolResponse& response);

    Status
    ShowPartitions(const proto::milvus::ShowPartitionsRequest& request,
                   proto::milvus::ShowPartitionsResponse& response);

    Status
    LoadPartitions(const proto::milvus::LoadPartitionsRequest& request, proto::common::Status& response);

    Status
    ReleasePartitions(const proto::milvus::ReleasePartitionsRequest& request, proto::common::Status& response);

    Status
    CreateAlias(const proto::milvus::CreateAliasRequest& request, proto::common::Status& response);

    Status
    DropAlias(const proto::milvus::DropAliasRequest& request, proto::common::Status& response);

    Status
    AlterAlias(const proto::milvus::AlterAliasRequest& request, proto::common::Status& response);

    Status
    CreateIndex(const proto::milvus::CreateIndexRequest& request, proto::common::Status& response);

    Status
    DescribeIndex(const proto::milvus::DescribeIndexRequest& request, proto::milvus::DescribeIndexResponse& response);

    Status
    GetIndexState(const proto::milvus::GetIndexStateRequest& request, proto::milvus::GetIndexStateResponse& response);

    Status
    GetIndexBuildProgress(const proto::milvus::GetIndexBuildProgressRequest& request,
                          proto::milvus::GetIndexBuildProgressResponse& response);

    Status
    DropIndex(const proto::milvus::DropIndexRequest& request, proto::common::Status& response);

    Status
    Flush(const proto::milvus::FlushRequest& request, proto::milvus::FlushResponse& response);

 private:
    std::unique_ptr<proto::milvus::MilvusService::Stub> stub_;
    std::shared_ptr<grpc::Channel> channel_;

    Status
    statusByProtoResponse(const proto::common::Status& status) {
        if (status.error_code() != proto::common::ErrorCode::Success) {
            return Status{StatusCode::SERVER_FAILED, status.reason()};
        }
        return Status::OK();
    }

    template <typename Response>
    Status
    statusByProtoResponse(const Response& response) {
        const auto& status = response.status();
        return statusByProtoResponse(status);
    }

    template <typename Request, typename Response>
    Status
    grpcCall(const char* name,
             grpc::Status (proto::milvus::MilvusService::Stub::*func)(grpc::ClientContext*, const Request&, Response*),
             const Request& request, Response& response) {
        if (stub_ == nullptr) {
            return {StatusCode::NOT_CONNECTED, "Connection is not ready!"};
        }

        ::grpc::ClientContext context;
        ::grpc::Status grpc_status = (stub_.get()->*func)(&context, request, &response);

        if (!grpc_status.ok()) {
            std::cerr << name << " failed!" << std::endl;
            return {StatusCode::SERVER_FAILED, grpc_status.error_message()};
        }

        return statusByProtoResponse(response);
    }
};

}  // namespace milvus
