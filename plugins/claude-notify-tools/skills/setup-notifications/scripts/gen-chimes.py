#!/usr/bin/env python3
"""Regenerate the bundled notification chimes (dev-only; output is committed).

Soft sine tones with a light 2nd/3rd harmonic, a 6 ms attack and an
exponential decay, peaking around -14 dBFS so they are easy to hear but
never harsh. 22.05 kHz mono 16-bit WAV plays everywhere (afplay, paplay,
pw-play, aplay, Windows SoundPlayer/MediaPlayer).

    python3 gen-chimes.py [output_dir]   # default: ../assets/sounds
"""
import math
import struct
import sys
import wave
from pathlib import Path

RATE = 22050
PEAK = 10 ** (-14 / 20)  # -14 dBFS


def note(freq, start, length, decay):
    return (freq, start, length, decay)


# (frequency Hz, start s, length s, decay time-constant s)
CHIMES = {
    # rising major third: "all done"
    "done.wav": [note(1046.5, 0.00, 0.55, 0.16), note(1318.5, 0.13, 0.65, 0.20)],
    # two gentle rising pings (fourth): "come look"
    "needs-you.wav": [note(880.0, 0.00, 0.40, 0.11), note(1174.7, 0.18, 0.60, 0.17)],
    # soft descending minor third, lower register: "something went wrong"
    "error.wav": [note(523.3, 0.00, 0.45, 0.14), note(440.0, 0.20, 0.70, 0.22)],
}


def render(notes):
    total = max(s + l for _, s, l, _ in notes)
    n = int(total * RATE) + 1
    buf = [0.0] * n
    for freq, start, length, decay in notes:
        s0 = int(start * RATE)
        for i in range(int(length * RATE)):
            t = i / RATE
            attack = min(1.0, t / 0.006)
            release = min(1.0, (length - t) / 0.03)  # avoid end click
            env = attack * release * math.exp(-t / decay)
            w = (math.sin(2 * math.pi * freq * t)
                 + 0.18 * math.sin(4 * math.pi * freq * t)
                 + 0.05 * math.sin(6 * math.pi * freq * t))
            if s0 + i < n:
                buf[s0 + i] += env * w
    m = max(abs(x) for x in buf) or 1.0
    return [x / m * PEAK for x in buf]


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "sounds"
    out.mkdir(parents=True, exist_ok=True)
    for name, notes in CHIMES.items():
        samples = render(notes)
        with wave.open(str(out / name), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(b"".join(struct.pack("<h", int(x * 32767)) for x in samples))
        print(f"wrote {out / name} ({len(samples) / RATE:.2f}s)")


if __name__ == "__main__":
    main()
