

KIND_INSTANCE=grafana-stack

K8S_NAMESPACE=observability

.PHONY: install
install: hack_k8s_connect
	helm upgrade --install loki --create-namespace --namespace=$(K8S_NAMESPACE) --values=helm/values.yaml grafana/loki-stack

.PHONY: port_forward_grafana
port_forward_grafana:
	kubectl port-forward --namespace $(K8S_NAMESPACE) service/loki-grafana 3000:80

.PHONY: hack_helm_add_repo
hack_helm_add_repo:
	helm repo add grafana https://grafana.github.io/helm-charts

# creates a K8s instance
.PHONY: hack_k8s_new
hack_k8s_new:
	kind create cluster --config ./kind/kind.yaml --name $(KIND_INSTANCE)

# deletes a k8s instance
.PHONY: hack_k8s_drop
hack_k8s_drop:
	kind delete cluster --name $(KIND_INSTANCE)

# sets KUBECONFIG for the K8s instance
.PHONY: hack_k8s_connect
hack_k8s_connect:
	kind export kubeconfig --name $(KIND_INSTANCE)

