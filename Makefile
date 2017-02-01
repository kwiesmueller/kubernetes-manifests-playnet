default: generate
use:
	kubectl config use-context playnet
generate:
	./generate.sh
format:
	find . -name "*.yaml" -exec yamlformat -write -path "{}" \;
installyamlformat:
	go get github.com/bborbe/yamlformat/bin/yamlformat
