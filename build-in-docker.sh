#! /bin/bash

set -exo pipefail

here="$(readlink -f "$(dirname "$0")")"
cd "$here"

workdir="$1"

if [[ "$workdir" == "" ]]; then
    echo "Usage: $0 <workdir>"
    exit 2
fi

if [[ ! -d "$workdir"/.git ]]; then
    mkdir -p "$workdir"
    pushd "$workdir"
    git clone https://github.com/RocketChat/Rocket.Chat.ReactNative .

    if [[ "$BRANCH" == "latest-release" ]]; then
        echo "Checking out latest release tag"
        git checkout "$(git tag | sort -V | grep -vE '^v' | grep -v rc | tail -n1)"
    elif [[ "$BRANCH" != "" ]]; then
        echo "Checking out branch $BRANCH"
        git checkout "$BRANCH"
    else
        echo "Using default branch"
    fi

    popd
fi

docker_image=rocketchat-reactnative-build

docker build -t "$docker_image" .

if tty -s; then
    extra_args=("-t")
fi

run_in_docker() {
    docker run -e ARCH --rm -i "${extra_args[@]}" --init -w /ws -v "$(readlink -f "$workdir")":/ws -v "$here":/scripts --user "$(id -u)" "$docker_image" "$@"
}

run_in_docker bash -lxe /scripts/build.sh
