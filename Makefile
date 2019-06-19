REGISTRY_URL ?= vothanhkiet/health-check
TAG ?= 1.0.0

build: build-linux build-darwin

build-linux:
	mkdir -p out
	docker build \
		--build-arg goos=linux \
		-f docker/build.Dockerfile \
		-t ${REGISTRY_URL}:latest \
		-t ${REGISTRY_URL}:${TAG} \
		.
	docker run --rm --name=test --entrypoint /bin/sh ${REGISTRY_URL}:latest -c "cat /go/bin/health-check" > ./out/health-check-linux

build-darwin:
	mkdir -p out
	docker build \
		--build-arg goos=darwin \
		-f docker/build.Dockerfile \
		-t ${REGISTRY_URL}:latest \
		-t ${REGISTRY_URL}:${TAG} \
		.
	docker run --rm --name=test --entrypoint /bin/sh ${REGISTRY_URL}:latest -c "cat /go/bin/health-check" > ./out/health-check-darwin

docker: docker-build docker-push

docker-build:
	docker build --build-arg goos=linux -f docker/hub.Dockerfile --squash -t ${REGISTRY_URL}:latest -t ${REGISTRY_URL}:${TAG} .

docker-push: 
	docker push ${REGISTRY_URL}:latest
	docker push ${REGISTRY_URL}:${TAG}