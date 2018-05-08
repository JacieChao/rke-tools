#!/bin/bash

REPO=${REPO:-jacie}

ARCH=amd64

case "$(uname -m)" in
  x86_64*)
    ARCH=amd64
    ;;
  i?86_64*)
    ARCH=amd64
    ;;
  amd64*)
    ARCH=amd64
    ;;
  aarch64*)
    ARCH=arm64
    ;;
  arm64*)
    ARCH=arm64
    ;;
  *)
    echo "Unsupported host arch. Must be x86_64, arm64." >&2
    exit 1
    ;;
esac

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    DIRTY="-dirty"
fi

COMMIT=$(git rev-parse --short HEAD)
GIT_TAG=$(git tag -l --contains HEAD | head -n 1)

if [[ -z "$DIRTY" && -n "$GIT_TAG" ]]; then
    VERSION=$GIT_TAG
else
    VERSION="${COMMIT}${DIRTY}"
fi

if [ "${ARCH}" != "amd64" ]; then
	docker build --file Dockerfile.${ARCH} -t $REPO/rke-tools:${VERSION}-${ARCH} .
	docker push $REPO/rke-tools:${VERSION}-${ARCH}
else
	docker build -t $REPO/rke-tools:${VERSION} .
	docker push $REPO/rke-tools:${VERSION}
fi
