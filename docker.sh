#!/usr/bin/env bash

docker run --rm --volume "`pwd`:/data" --entrypoint "/data/scripts/build.sh" pandoc/latex

