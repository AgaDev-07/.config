#!/bin/bash
require() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: falta '$1'" >&2
    exit 1
  fi
}