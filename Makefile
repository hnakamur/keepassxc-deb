DOCKER_IMAGE_NAME=keepassxc-deb
UPSTREAM_VER=2.7.5
DEB_VER=$(UPSTREAM_VER)-1hnakamur1ubuntu22.04
DEB_ARCH=$(shell dpkg --print-architecture)

build:
	docker build --no-cache --progress=plain \
		--build-arg UPSTREAM_VER=$(UPSTREAM_VER) \
		--build-arg DEB_VER=$(DEB_VER) \
		-t $(DOCKER_IMAGE_NAME) . 2>&1 | tee build.log
	zstd -19 --rm build.log
	docker run --rm -v .:/dist --entrypoint=cp $(DOCKER_IMAGE_NAME) \
		/home/build/keepassxc_$(DEB_VER)_$(DEB_ARCH).deb /dist/

release:
	if ! git rev-parse $(DEB_VER) >/dev/null 2>/dev/null; then \
		git tag $(DEB_VER); \
	fi
	git push origin main
	git push origin --tags
	gh release create -n '' --target main -t $(DEB_VER) $(DEB_VER) \
		keepassxc_$(DEB_VER)_$(DEB_ARCH).deb \
		build.log.zst

build_with_cache:
	docker build --progress=plain \
		--build-arg UPSTREAM_VER=$(UPSTREAM_VER) \
		--build-arg DEB_VER=$(DEB_VER) \
		-t $(DOCKER_IMAGE_NAME) .
	docker run --rm -v .:/dist --entrypoint=cp $(DOCKER_IMAGE_NAME) \
		/home/build/keepassxc_$(DEB_VER)_$(DEB_ARCH).deb /dist/

.PHONY: build release build_with_cache
