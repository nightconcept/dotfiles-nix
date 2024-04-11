#!/usr/bin/env bash

# faster decryption because I'm lazy
# source: https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/

# reference only:
# pbpaste | base64 --decode > ./secret-key

# add to the environment because this is a live install
nix-env -iA nixos.git-crypt

# just supply secret-key!
git-crypt unlock ./secret-key