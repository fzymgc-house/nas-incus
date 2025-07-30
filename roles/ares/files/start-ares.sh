#!/usr/bin/env bash

# shellcheck disable=SC1090
source ~/.bashrc

cd ~ares/aresmush || exit 1

exec bin/startares
