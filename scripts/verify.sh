#!/bin/sh

. ./common.sh

phrase="$1";
if [ -z "$phrase" ]; then
  echo "Usage: verify.sh <phrase name>" >&2
  exit 1
fi

filename="$(get_phrase_file "$phrase")"
if [ ! -f "$filename" ] || [ ! -s "$filename" ]; then
  echo "Seed phrase $phrase is not present: $filename is missing or empty" >&2
  exit 1
fi

i="0";
while IFS= read -r item; do 
  i=$(( i + 1 ));
  if [ "$i" -eq "1" ]; then phrase_name="$item"
  elif [ "$i" -eq "2" ]; then phrase_size="$item"
  elif [ "$i" -eq "3" ]; then phrase_hash="$item"
  elif [ "$i" -eq "4" ]; then phrase_hint="$item"
  fi
done < $filename

echo "Write down your $phrase_size-word $phrase seed phrase" >&2
recv_hash="$(read_phrase_hash "$phrase_size")"
if [ "$recv_hash" = "$phrase_hash" ]; then
  echo "Seed phrase is correct. Well done :)" >&2
else
  echo "Phrase not matched." >&2
  exit 1
fi

