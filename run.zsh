#!/usr/bin/env zsh

# Please change the URL appropriately
URL=""

OUT="resp"
rm -rf "$OUT"; mkdir -p "$OUT"

seq 1 600 | xargs -P60 -I{} sh -c "curl -s '$URL' > '$OUT/{}.html'"

for f in "$OUT"/*.html; do stat -f%z "$f"; done | sort -n | uniq -c

NORMAL=$(for f in "$OUT"/*.html; do stat -f%z "$f"; done \
         | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')

found=0
for f in "$OUT"/*.html; do
  sz=$(stat -f%z "$f")
  if [ "$sz" != "$NORMAL" ]; then
    found=1
    echo "----- $f ($sz bytes) -----"
    cat "$f"
    echo
  fi
done
[ "$found" = 0 ] && echo "(none — every response was the decoy)"

for f in "$OUT"/*.html; do
  echo "$(shasum -a 1 "$f" | awk '{print $1}')  $f"
done | awk '{print $1}' | sort | uniq -c