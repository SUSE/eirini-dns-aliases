.PHONY: binary image

image:
	ruby build/kubecf-tools/build-scripts/build-docker-image.rb \
		--prefix=image build/manifest.yaml

binary:
	ruby build/kubecf-tools/build-scripts/build-go-binary.rb \
		--prefix=binary build/manifest.yaml
