APP ?= demo-nginx
NAMESPACE ?= $(APP)
GIT_URL ?= https://github.com/you/your-repo.git
GIT_PATH ?= charts/$(APP)

.PHONY: convert deploy-oc deploy-helm bootstrap-gitops package clean

convert:
	bash scripts/convert.sh

deploy-oc:
	bash scripts/deploy-oc-yaml.sh

deploy-helm:
	bash scripts/deploy-helm.sh

bootstrap-gitops:
	bash scripts/bootstrap-gitops.sh

package:
	helm package charts/$(APP)

clean:
	rm -rf generated/k8s/$(APP)/*.yaml charts/$(APP)-*.tgz
