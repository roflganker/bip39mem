#!/bin/sh

. ./common.sh

read_new_phrase_name() {
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

read_new_word_count() {
  local cnt;
  while [ "$cnt" != "24" ] && [ "$cnt" != "12" ]; do
    read -p "Word count, 12 or 24? " -r cnt
  done

  echo "$cnt"
}

read_new_phrase_hint() {
  local hint
  read -p "🧠 Write a hint/association (optional) " -r hint
  echo "$hint";
}

phrase_name="$(read_new_phrase_name)"
phrase_size="$(read_new_word_count)"
phrase_hash="$(read_phrase_hash "$phrase_size")"
phrase_hint="$(read_new_phrase_hint)";
phrase_file="$(get_phrase_file "$phrase_name")";

touch $phrase_file
chmod 600 $phrase_file
echo "$phrase_name" > $phrase_file
echo "$phrase_size" >> $phrase_file
echo "$phrase_hash" >> $phrase_file
echo "$phrase_hint" >> $phrase_file

echo "$phrase_file"

