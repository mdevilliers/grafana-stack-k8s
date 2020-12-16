
.PHONY: hack_k8s_new
hack_k8s_new:
	kind create cluster --config ./kind/kind.yaml --name grafana-stack

.PHONY: hack_k8s_drop
hack_k8s_drop:
	kind delete cluster --name grafana-stack

.PHONY: hack_k8s_connect
hack_k8s_connect:
	kind export kubeconfig --name grafana-stack
