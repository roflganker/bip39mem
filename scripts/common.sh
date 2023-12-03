#!/bin/sh

bip39mem_home_dir="$HOME/.bip39mem"

# Obtain filename of a seed-phtase
get_phrase_file() {
  local name=$1
  if [ -z "$name" ]; then
    echo "get_phrase_file got no arguments"
    exit 1
  fi

  echo "$bip39mem_home_dir/$name.bip39"
}

# Read a secret from stdin; POSIX-compatible
read_secret() {
  local prompt=$1
  stty -echo
  local secret
  read -p "$prompt" -r secret
  stty echo

  echo "$secret"
}

# Read a seed phrase from stdin and return its hash
read_phrase_hash() {
  local word_list="../words.txt"
  local word_count="${1:-12}"
  local phrase_hash="Waterfall"
  local word_index="1"
  while [ "$word_index" -le "$word_count" ]; do
    local word=$(read_secret "Word $word_index -> ");

    local line=$(grep -Fxn "$word" "$word_list");
    if [ -z "$line" ]; then
      echo "Not a BIP39 word." >&2;
      continue;
    fi

    local num=${line%%:*}  # Order number of a BIP39 word, starting with 1
    echo "Got it" >&2
    phrase_hash=$(echo "$phrase_hash $word" | sha256sum | cut -c 1-64)
    word_index=$(( word_index + 1 ))
  done

  echo "$phrase_hash"
}

