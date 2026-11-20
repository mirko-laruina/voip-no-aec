#!/system/bin/sh
# At boot, build a copy of audio_effects.xml without the "aec" effect and bind-mount it over the original.
# Runs before audioserver and the audio HAL start, so they read the patched file.
MODDIR=${0%/*}
LOG=$MODDIR/last_run.log
: > "$LOG"

# Android uses the first file found in this order: patch only that one.
for SRC in /odm/etc/audio_effects.xml /vendor/etc/audio_effects.xml /system/etc/audio_effects.xml; do
  [ -f "$SRC" ] && break
done
[ -f "$SRC" ] || { echo "no audio_effects.xml found" >> "$LOG"; exit 0; }

OUT=$MODDIR/audio_effects.xml
# shortcut: removes only single-line "aec" entries (AOSP format); other layouts are left unchanged.
sed -e '/<effect[^>]*name="aec"/d' -e '/<apply[^>]*effect="aec"/d' "$SRC" > "$OUT.tmp"
if [ ! -s "$OUT.tmp" ] || cmp -s "$SRC" "$OUT.tmp"; then
  echo "$SRC: no aec found, not mounted" >> "$LOG"
  rm -f "$OUT.tmp"
  exit 0
fi
mv -f "$OUT.tmp" "$OUT"
chmod 644 "$OUT"
chcon "$(ls -Z "$SRC" | cut -d' ' -f1)" "$OUT"
if mount -o bind "$OUT" "$SRC"; then
  echo "$SRC: aec removed, mounted" >> "$LOG"
else
  echo "$SRC: mount failed" >> "$LOG"
fi
