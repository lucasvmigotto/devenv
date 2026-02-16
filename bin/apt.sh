#!/usr/bin/env bash

set -e

function main() {

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -qq > /dev/null

    apt-get install \
        --yes --no-install-recommends -qq \
        ${@} > /dev/null

    rm -rf /var/lib/apt/lists/*

}

main $@
