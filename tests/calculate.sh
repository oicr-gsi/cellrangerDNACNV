#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

ls | sed 's/.*\.//' | sort | uniq -c
