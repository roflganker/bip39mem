#!/bin/sh


get_phrase_file() {
  local home_dir="$HOME/.bip39mem"
  local name=$1
  if [ -z "$name" ]; then
    echo "get_phrase_file got no arguments"
    exit 1
  fi

  echo "$home_dir/$name.bip39"
}

read_phrase_name() {
  local name
  local default="trading"
  while true; do
    read -p "Seed phrase name? As example, \"$default\": " -r name;
    name="${name:-${default}}"
    if !(echo "$name" | grep -Eq '^[a-zA-Z0-9_-]+$'); then
      echo "Please avoid special chars and spaces" >&2;
      continue;
    fi
    if [ -f "$(get_phrase_file $name)" ]; then
      echo "Phrase is already present. Enter different name" >&2
      continue
    fi
    break
  done

  echo "$name"
}

read_word_count() {
  local cnt;
  while [ "$cnt" != "24" ] && [ "$cnt" != "12" ]; do
    read -p "Word count, 12 or 24? " -r cnt
  done

  echo "$cnt"
}

read_secret() {
  local prompt=$1
  stty -echo
  local secret
  read -p "$prompt" -r secret
  stty echo

  echo "$secret"
}

read_phrase_hash() {
  local word_list='../words.txt'
  local word_count="${1:-12}"
  local hash_base="Waterfall"
  local phrase_hash="$hash_base"
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

read_phrase_hint() {
  local hint
  read -p "🧠 Write a hint/association (optional) " -r hint
  echo "$hint";
}

phrase_name="$(read_phrase_name)"
phrase_size="$(read_word_count)"
phrase_hash="$(read_phrase_hash "$phrase_size")"
phrase_hint="$(read_phrase_hint)";
phrase_file="$(get_phrase_file "$phrase_name")";

touch $phrase_file
chmod 600 $phrase_file
echo "$phrase_name" > $phrase_file
echo "$phrase_size" >> $phrase_file
echo "$phrase_hash" >> $phrase_file
echo "$phrase_hint" >> $phrase_file

echo "$phrase_file"

