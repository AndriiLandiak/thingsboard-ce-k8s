#!/bin/bash
#
# Copyright © 2016-2020 The Thingsboard Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function installEdge() {

    kubectl apply -f tb-edge-db-configmap.yml

    kubectl apply -f tb-cache-configmap.yml
    kubectl apply -f tb-edge-configmap.yml
    kubectl apply -f tb-kafka-configmap.yml

    kubectl rollout status statefulset/zookeeper
    kubectl rollout status statefulset/tb-kafka
    kubectl rollout status deployment/tb-redis
    kubectl apply -f database-setup.yml &&
    kubectl wait --for=condition=Ready pod/tb-db-setup --timeout=120s &&
    kubectl exec tb-db-setup -- sh -c 'export INSTALL_TB_EDGE=true; start-tb-edge-node.sh; touch /tmp/install-finished;'

    kubectl delete pod tb-db-setup

}

kubectl apply -f tb-namespace.yml || echo
kubectl config set-context $(kubectl config current-context) --namespace=thingsboard
kubectl apply -f thirdparty.yml

installEdge
