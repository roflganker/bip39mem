#!/bin/bash

homedir="$HOME/.bip39mem"
if [ ! -d $homedir ]; then
  if ! mkdir -m 700 $homedir; then
    echo "Failed to create home dir at $homedir" >&2
    exit 1
  fi
fi

while [[ ! "$phrase_name" =~ ^[a-zA-Z0-9_-]+$ ]]; do
  read -p 'Passphrase name? As example, "trading" ' -r phrase_name
  if [[ -z "$phrase_name" ]]; then phrase_name="trading"; fi
done
echo "Working on $phrase_name passphrase" >&2

phrase_file="$homedir/$phrase_name.bip39"
if [ -f "$phrase_file" ]; then
  echo "File already exists. Aborting." >&2
  exit 1
fi

while [[ ("$word_count" != "24") && ("$word_count" != "12") ]]; do
  read -p "Word count, 12 or 24? " -r word_count
done
echo "Word count is $word_count" >&2

phrase_hash="Waterfall"
word_index="1"
word_list="../words.txt"
while [ "$word_index" -le "$word_count" ]; do
  read -p "Word $word_index > " -s -r word;  
  if grep -Fxq "$word" "$word_list"; then
    echo "Got it." >&2;
  else
    echo "Not a BIP39 word" >&2;
    continue;
  fi
  phrase_hash=$(echo "$phrase_hash $word" | sha256sum | cut -c 1-64)
  word_index=$(( word_index + 1 ));
done
echo "Got your passphrase" >&2
echo "Hash is $phrase_hash" >&2

touch $phrase_file
chmod 600 $phrase_file
printf '%s\n%s\n%s\n' $phrase_name $word_count $phrase_hash > $phrase_file
echo "Saved to $phrase_file." >&2

