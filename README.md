# voip-no-aec

APatch / Magisk / KernelSU module that disables the system AEC (acoustic echo canceller) effect.

## Why
On some Qualcomm devices running a newer Android over older vendor blobs
(tested: moto g 5G `kiev`, LineageOS 23 / Android 16), enabling the system AEC
makes the HAL route the echo reference in a way that slows microphone capture
to ~2/3 of real time. In VoIP calls (WhatsApp, Meet, ...) the other side hears
you crackling, choppy and with growing delay. Normal calls and voice notes are fine.

Without the system AEC, apps use their own echo cancellation and capture runs in real time.

## How it works
At boot (`post-fs-data`), before audioserver and the audio HAL start, the script:
1. picks the first `audio_effects.xml` Android would load (`/odm/etc`, `/vendor/etc`, `/system/etc`);
2. writes a copy without the `aec` effect lines (`ns` and other effects stay);
3. bind-mounts the copy over the original, with the same SELinux context.

Nothing on `/vendor` is modified. Result is logged in the module folder (`last_run.log`).
If no `aec` entry is found, nothing is mounted.

## Install / remove
Flash the zip from the root manager, reboot. Disable or remove the module and reboot to revert.

## Limits
Only single-line AOSP-style `aec` entries are matched. Some apps seem to switch to the `MIC`
source when the system AEC is not available (e.g. WhatsApp): system noise suppression then
no longer applies, so enable the app's own noise cancellation.

## Disclaimer
Use at your own risk.
