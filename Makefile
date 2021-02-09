

KIND_INSTANCE=grafana-stack

K8S_OBS_NAMESPACE=observability
K8S_APP_NAMESPACE=demo

# install adds loki-stack and jaegar
.PHONY: install_observability
install_observability: hack_k8s_connect
	helm upgrade --install loki --create-namespace --namespace=$(K8S_OBS_NAMESPACE) --values=helm/loki-stack/values.yaml grafana/loki-stack
	helm upgrade --install jaeger --create-namespace --namespace=$(K8S_OBS_NAMESPACE) jaegertracing/jaeger-operator
	helm upgrade --install prometheus --create-namespace --namespace=$(K8S_OBS_NAMESPACE) --values=helm/prometheus/values.yaml prometheus-community/kube-prometheus-stack
	kubectl apply -n $(K8S_OBS_NAMESPACE) -f ./k8s/jaeger/instance.yaml
	kubectl apply -n $(K8S_OBS_NAMESPACE) -f ./k8s/prometheus/instance.yaml


.PHONY: port_forward_grafana
port_forward_grafana:
	kubectl port-forward --namespace $(K8S_OBS_NAMESPACE) service/loki-grafana 3000:80

.PHONY: hack_helm_add_repo
hack_helm_add_repo:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

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

# built from https://github.com/mdevilliers/open-telemetery-golang-bestiary
.PHONY: hack_k8s_side_load
hack_k8s_side_load:
	kind load docker-image open-telem-demo/svc-one --name $(KIND_INSTANCE)
	kind load docker-image open-telem-demo/client-api --name $(KIND_INSTANCE)

.PHONY: install_apps
install_apps: hack_k8s_connect
	kubectl apply -f ./k8s/open-telem-demo/namespace.yaml
	kubectl apply -n $(K8S_APP_NAMESPACE) -f ./k8s/open-telem-demo/application-deployments.yaml
