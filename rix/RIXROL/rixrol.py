#!/usr/bin/env python3
"""
RIX -> AdLib Visual Composer ROL 0.4

Test-oriented converter based on a minimal known RIX/ROL pair.

Important reconstructed rule:
    RIX delay units are 1/1000 second, so one RIX delay unit is about 1.0 ms.
    (v11 used the disassembly-derived clock 70 Hz x 14 units = 980 units/s;
    v12+ use the logical millisecond clock 1000 units/s.  Every constant in
    this file -- tick_converter, bpm_tick_fit (rate = bpm*tickBeat/60000) and
    the analytic plateau solver (plateau_bounds / refine_rms_minimum)
    -- all assume the SAME clock;
    the two conventions are never mixed.)
    ROL timing is reconstructed from:
        tickBeat = ticks per beat
        actual BPM = supplied/measured playback BPM

ROL tempo handling:
    basicTempo * tempo_multiplier = actual BPM
    therefore basicTempo = actual BPM / tempo_multiplier

The RIX format itself has no ROL tempo-multiplier field; the multiplier
comes from the ROL tempo track. Use --tempo-multiplier when it is known.

For the known four-note test:
    RIX delay = 2000 ms
    ROL = 16 ticks
    BPM = 120
    tickBeat = 4
    => 8 ROL ticks/sec, 16 ticks per 2 sec.

The script writes:
    <name>_rebuild.ROL
    <name>_rebuild.BNK       (minimal BNK containing referenced RIX patches)
    <name>_rebuild.txt       (decoder/statistics report)

The BNK writer is intentionally conservative. If a matching original
INS/BNK is available, use it for comparison; the ROL itself references
the generated instrument names.

v14 adds ONE manual switch: --tempo-map.
  OFF (default): behaviour is byte-identical to v13.  When the sliding-window
      detector measures the piece as re-tempoed mid-song, a short advisory is
      appended to stdout recommending --tempo-map (advisory only; artifacts
      are untouched).
  ON: treat the piece as a variable-tempo composition.  fit_tempo_segments()
      splits the onset stream at phrase-period breaks, each segment is
      fitted with local_onset_fit(), octave jumps in notation are folded to
      beat level, and the whole map is written as a multi-event ROL tempo
      track (basicTempo at the grid tempo + one multiplier per segment).
      The grid scale (power of two) is the smallest that lets every same-
      segment onset gap fill at least one tick; playback timing is
      scale-invariant.  If no reliable boundaries are found the v13 path
      runs instead.  --tempo-map is mutually exclusive.
"""

from __future__ import annotations
import argparse
import math
import os
import struct
import subprocess
import sys
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path

# Single source of truth for the RIX clock. v11 used 70*14 = 980 units/s
# (disassembly); v12+ use the logical millisecond clock 1000 units/s.
# tick_converter, bpm_tick_fit and the plateau solver all derive from this one.
RIX_UNITS_PER_SEC = 1000


@dataclass
class Event:
    time_rix: int
    channel: int
    typ: str
    value: int
    raw: int


def cstr(s: str, n: int) -> bytes:
    return s.encode("ascii", errors="replace")[:n-1].ljust(n, b"\0")


def read_rix(path: Path):
    data = path.read_bytes()
    if len(data) < 22:
        raise ValueError("RIX file is too short")

    sig = struct.unpack_from("<H", data, 0)[0]
    mode = data[2]
    ins_off = struct.unpack_from("<H", data, 8)[0]
    pat_off = struct.unpack_from("<H", data, 12)[0]

    if sig != 0x55AA:
        raise ValueError(f"Not a RIX file: signature 0x{sig:04X}")
    if not (0x14 <= ins_off < len(data)):
        raise ValueError("Invalid INS offset")
    if not (pat_off < len(data)):
        raise ValueError("Invalid pattern offset")

    events: list[Event] = []
    referenced = set()
    pos = pat_off
    t = 0

    while pos + 1 < len(data):
        word = struct.unpack_from("<H", data, pos)[0]
        if word == 0x8000:
            break

        hi = word >> 8
        lo = word & 0xFF
        cmd = hi >> 4
        ch = hi & 0x0F

        if cmd == 0x09:
            events.append(Event(t, ch, "instrument", lo, word))
            referenced.add(lo)
        elif cmd == 0x0A:
            events.append(Event(t, ch, "pitch", lo, word))
        elif cmd == 0x0B:
            events.append(Event(t, ch, "volume", lo, word))
        elif cmd == 0x0C:
            events.append(Event(t, ch, "off" if lo == 0 else "note", lo, word))
        else:
            t += word

        pos += 2

    return {
        "data": data,
        "signature": sig,
        "mode": mode,
        "ins_offset": ins_off,
        "pattern_offset": pat_off,
        "events": events,
        "instruments": sorted(referenced),
        "duration_rix": t,
    }


def rix_patch(data: bytes, ins_off: int, number: int) -> bytes:
    """
    RIX instrument slots are 0x40 bytes. The useful patch portion is
    the first 0x38 (56) bytes, matching the original RIX/INS relationship.

    The first 28 16-bit fields map to the two 13-field OPLREGS blocks
    followed by the two waveform fields used by the 30-byte BNK timbre.
    """
    base = ins_off + number * 0x40
    raw = data[base:base + 0x40]
    if len(raw) < 0x38:
        raise ValueError(f"RIX instrument {number} is truncated")
    words = struct.unpack("<28H", raw[:56])
    vals = bytes(w & 0xFF for w in words)

    # Minimal 28-byte instrument definition:
    # type/rhythm + 13 modulator bytes + 13 carrier bytes + 2 wave bytes
    return b"\0\0" + vals[:13] + vals[13:26] + bytes([vals[26] & 3, vals[27] & 3])


def find_standard_bnk(rix_path: Path) -> Path | None:
    """Find STANDARD.BNK in the same directory as the input RIX."""
    exact = rix_path.parent / "STANDARD.BNK"
    if exact.is_file():
        return exact

    # Be a little more tolerant on case-sensitive hosts while keeping the
    # intended lookup strictly in the RIX directory.
    try:
        for p in rix_path.parent.iterdir():
            if p.is_file() and p.name.upper() == "STANDARD.BNK":
                return p
    except OSError:
        pass
    return None


def read_standard_bnk(path: Path):
    """Read standard AdLib BNK names and their 30-byte PackedTimbres."""
    data = path.read_bytes()
    if len(data) < 28:
        raise ValueError("STANDARD.BNK is too short")

    ver_major, ver_minor, sig, num_used, num_instruments, off_name, off_data = \
        struct.unpack_from("<BB6sHHII", data, 0)
    if sig != b"ADLIB-":
        raise ValueError("STANDARD.BNK has an invalid ADLIB signature")
    if off_name > len(data) or off_data > len(data):
        raise ValueError("STANDARD.BNK has invalid offsets")

    entries = []
    for i in range(num_instruments):
        pos = off_name + i * 12
        if pos + 12 > len(data):
            raise ValueError("STANDARD.BNK name table is truncated")
        index, flags = struct.unpack_from("<HB", data, pos)
        name = data[pos + 3:pos + 12].split(b"\0", 1)[0].decode("ascii", "replace")
        patch_pos = off_data + index * 30
        if patch_pos + 30 > len(data):
            raise ValueError("STANDARD.BNK instrument data is truncated")
        patch = data[patch_pos:patch_pos + 30]
        if flags:
            entries.append((name, patch))

    return entries


def match_standard_instruments(rix, standard_path: Path | None):
    """Map RIX instrument numbers to STANDARD.BNK names by exact patch data."""
    names = {n: f"RIX{n:02d}" for n in rix["instruments"]}
    if standard_path is None:
        return names, {}, None

    try:
        entries = read_standard_bnk(standard_path)
    except (OSError, ValueError) as exc:
        print(f"Warning: cannot use STANDARD.BNK ({exc}); using RIX names.")
        return names, {}, None

    # The RIX INS -> BNK conversion already normalizes the useful OPL data to
    # the same 30-byte PackedTimbre representation used by STANDARD.BNK.
    by_patch = {}
    for name, patch in entries:
        by_patch.setdefault(patch, name)

    matched = {}
    for n in rix["instruments"]:
        patch = rix_patch(rix["data"], rix["ins_offset"], n)
        name = by_patch.get(patch)
        if name:
            names[n] = name
            matched[n] = name

    return names, matched, len(entries)


def write_bnk(path: Path, patches: dict[int, bytes], names: dict[int, str] | None = None):
    """
    Write a standard AdLib Visual Composer BNK bank.

    Layout (verified against STANDARD.BNK):
      28-byte header
      N * 12-byte name records: <H index><B flags><char[9] name>
      N * 30-byte PackedTimbre records

    Name records must be alphabetically sorted for AdLib's tools.  For
    instruments not found in STANDARD.BNK, the existing RIX## naming rule
    is preserved.
    """
    names = names or {}
    entries = [
        (names.get(n, f"RIX{n:02d}"), n, patches[n])
        for n in sorted(patches)
    ]
    entries.sort(key=lambda x: x[0].upper())

    count = len(entries)
    header_size = 28
    name_rec_size = 12
    patch_size = 30
    offset_name = header_size
    offset_data = offset_name + count * name_rec_size

    out = bytearray()
    out += struct.pack(
        "<BB6sHHII8s",
        1, 0, b"ADLIB-",
        count, count,
        offset_name, offset_data,
        b"\0" * 8,
    )

    for data_index, (name, _num, _patch) in enumerate(entries):
        out += struct.pack("<HB", data_index, 1)
        out += cstr(name, 9)

    assert len(out) == offset_data

    for _name, _num, patch in entries:
        if len(patch) != patch_size:
            raise ValueError(f"BNK patch has {len(patch)} bytes, expected 30")
        out += patch

    assert len(out) == offset_data + count * patch_size
    path.write_bytes(out)

def _rms_at(bpm, points, tick_beat):
    if not points:
        return 0.0
    k = tick_beat / float(60 * RIX_UNITS_PER_SEC)
    s = 0.0
    for u in points:
        x = k * bpm * u
        e = x - math.floor(x + 0.5)
        s += e * e
    return math.sqrt(s / len(points))


def build_segment_model(multiplier, tick_beat, segs, duration_units,
                        base_bpm_hint=None):
    """
    Piecewise-tempo mapping u(RIX units) -> ROL tick for a tempo-map build.

    segs: [{"u0","bpm","rms","rpts"}, ...] from fit_tempo_segments, ordered,
    first at u0 == 0.  Each segment's grid is RELATIVE to its own start
    (rpts = onsets minus u0), so the piecewise tick stream is continuous and
    every segment gets its own optimal phase -- exactly what the per-segment
    rms numbers describe.

    The written track carries basicTempo = bpm0/multiplier plus a multiplier
    event (bpm_i/bpm0) at each segment-start tick: ROL playback bpm at tick
    t = basicTempo * last tempo event at or before t, so v13's single-event
    track is the one-event special case.

    Musical octave: doubling a segment's bpm doubles its tick stream AND
    the playback tempo (wall-clock fit unchanged, music one octave faster),
    so the octave is a reading choice, exactly like v13's plateau octave
    picked by --bpm.  Each segment is first folded to its neighbour octave
    ((0.5, 2] around the previous segment via _octave_align): notation-level
    jumps that are really the same beat pulse (MUS61: 16th runs at 257 BPM
    are the same ~65 BPM beat as the preceding ~50s) collapse into the
    accelerando the listener hears: 49.9 -> 56.0 -> 61.9 -> 66.3 -> 64.2 ->
    69.2 BPM.

    Grid resolution: ROL has no sub-tick resolution, so the whole (aligned)
    map is then raised by the SMALLEST power of two whose ticks per second
    give every same-segment onset gap at least one whole tick (grace notes
    survive; playback is bit-identical since ticks and ticks/sec scale
    together), subject to the 65536-tick 16-bit space.  If no scale fits,
    stay as low as possible and report the co-landed segments.  --bpm (or
    the detector centre) only breaks ties upward when it lands closer.
    Returns (basic_tempo, base_tps, model).
    """
    if not segs or segs[0]["u0"] != 0:
        raise ValueError("segments must start at u0 == 0")
    us = [s["u0"] for s in segs]
    bpms = [s["bpm"] for s in segs]
    for i in range(1, len(bpms)):
        bpms[i] = _octave_align(bpms[i], bpms[i - 1])
    beat_bpms = list(bpms)          # played (beat-level) tempi
    # shortest SAME-SEGMENT onset gap (relative frame, never across u0):
    seg_gaps = []
    for s in segs:
        pts = sorted(set(s["rpts"]))
        g = 1 << 30
        for a, b in zip(pts, pts[1:]):
            if b > a:
                g = min(g, b - a)
        seg_gaps.append(1 if g > (1 << 29) else g)

    def cont_end(b0):
        t = 0.0
        for i in range(len(us) - 1):
            t += (us[i + 1] - us[i]) * b0[i] / 60.0 * tick_beat / 1000.0
        t += (duration_units - us[-1]) * b0[-1] / 60.0 * tick_beat / 1000.0
        return t

    m = None
    for o in range(0, 9):
        cand = [b * 2 ** o for b in bpms]
        if cont_end(cand) > 60000.0:
            break
        if all(g * b * tick_beat / 60000.0 >= 1.0
               for g, b in zip(seg_gaps, cand)):
            m = o
            break
    if m is None:
        m = 0
    if base_bpm_hint and base_bpm_hint > 0:
        for o in range(m, 9):
            cand = [b * 2 ** o for b in bpms]
            if cont_end(cand) > 60000.0:
                break
            if abs(bpms[0] * 2 ** o - base_bpm_hint) < \
                    abs(bpms[0] * 2 ** m - base_bpm_hint):
                m = o
    scale = 2 ** m
    bpms = [b * scale for b in bpms]
    collisions = [i for i, (g, b) in enumerate(zip(seg_gaps, bpms))
                  if g * b * tick_beat / 60000.0 < 1.0]

    bounds = [0]
    cum = [0.0]
    tps = []
    for i, b in enumerate(bpms):
        tps.append(b / 60.0 * tick_beat)
        if i + 1 < len(bpms):
            nxt = cum[i] + (us[i + 1] - us[i]) * tps[i] / 1000.0
            bnd = int(math.floor(nxt + 0.5))
            bounds.append(max(bnd, bounds[-1] + 1))
            cum.append(float(bounds[-1]))
    if bounds[-1] > 0xFFFE:
        raise ValueError("tempo-map tick stream exceeds the 16-bit space")
    basic = bpms[0] / multiplier
    mults = [round(multiplier * b / bpms[0], 6) for b in bpms]
    for m in mults:
        if not (0.01 <= m <= 10.0):
            raise ValueError(f"segment multiplier {m} outside 0.01..10.0")
    model = {"bounds": bounds, "cum": cum, "tps": tps, "us": us,
             "bpms": bpms, "beat_bpms": beat_bpms, "mults": mults,
             "scale": scale, "seg_gaps": seg_gaps,
             "collisions": collisions,
             "tick_beat": tick_beat,
             "basic_tempo": basic, "base_tps": tps[0]}
    return basic, tps[0], model


def _tick_of(u: int, model) -> int:
    i = 0
    for j, ub in enumerate(model["us"]):
        if u >= ub:
            i = j
        else:
            break
    return model["bounds"][i] + int(math.floor(
        (u - model["us"][i]) * model["tps"][i] / 1000.0 + 0.5))


def tick_converter(bpm: float, tick_beat: int, model=None):
    if tick_beat <= 0 or (bpm <= 0 and model is None):
        raise ValueError("BPM and tickBeat must be positive")
    if model is not None:
        ticks_per_second = model["base_tps"]

        def convert(rix_units: int) -> int:
            return _tick_of(rix_units, model)
        return ticks_per_second, convert
    ticks_per_second = bpm / 60.0 * tick_beat
    rix_units_per_second = float(RIX_UNITS_PER_SEC)

    def convert(rix_units: int) -> int:
        # Convert the absolute RIX position directly, then round once.
        # Do NOT round each delay separately: that creates cumulative drift.
        return int(math.floor(rix_units * ticks_per_second / rix_units_per_second + 0.5))

    return ticks_per_second, convert


def reconstruct(rix, bpm: float, tick_beat: int, beat_measure: int, instrument_names=None, model=None):
    events = rix["events"]
    instrument_names = instrument_names or {}
    ticks_per_second, to_tick = tick_converter(bpm, tick_beat, model=model)

    # RIX noteSelect is itself a complete monophonic channel state change.
    # Preserve every Cx value, including 0 (mute/rest), at its absolute time.
    # ROL voice events are then the successive state spans on each channel.
    note_events = [[] for _ in range(11)]
    notes = [[] for _ in range(11)]

    timbre = [[] for _ in range(11)]
    volume = [[] for _ in range(11)]
    pitch = [[] for _ in range(11)]

    max_tick = 0

    for e in events:
        if e.channel >= 11:
            continue
        ch = e.channel
        tick = to_tick(e.time_rix)
        max_tick = max(max_tick, tick)

        if e.typ == "instrument":
            timbre[ch].append((tick, instrument_names.get(e.value, f"RIX{e.value:02d}"), e.value))

        elif e.typ == "volume":
            # Known original sample: RIX 96 -> ROL 0.75.
            # Therefore 128 is nominally 1.0.
            volume[ch].append((tick, min(1.0, max(0.0, e.value / 128.0))))

        elif e.typ == "pitch":
            # Known sample: RIX 128 -> ROL 1.0.
            # Preserve the center exactly. For now map the 8-bit value
            # linearly onto the ROL 0..2 range. The exact RIX extended
            # pitch-bend curve remains a separate investigation.
            pitch[ch].append((tick, e.value / 128.0))

        elif e.typ in ("note", "off"):
            # Parser represents Cx00 as "off"; ROL represents it as note 0.
            value = e.value if e.typ == "note" else 0
            if note_events[ch] and note_events[ch][-1][0] == tick:
                note_events[ch][-1] = (tick, value)
            else:
                note_events[ch].append((tick, value))

    # The final state span runs to the RIX EOF absolute time.
    end_tick = to_tick(rix["duration_rix"])
    max_tick = max(max_tick, end_tick)

    for ch in range(11):
        evs = note_events[ch]
        for i, (start, value) in enumerate(evs):
            next_tick = evs[i + 1][0] if i + 1 < len(evs) else end_tick
            if next_tick > start:
                notes[ch].append((value, next_tick - start))

    return {
        "notes": notes,
        "timbre": timbre,
        "volume": volume,
        "pitch": pitch,
        "end_tick": end_tick,
        "ticks_per_second": ticks_per_second,
        "beat_measure": beat_measure,
    }


def tempo_track(actual_bpm: float, tempo_multiplier: float, tempo_events=None):
    # ROL playback speed is controlled by basicTempo * multiplier.
    # Keep the multiplier and solve for the Basic Tempo that produces the
    # requested actual BPM.  The tempo event is placed at tick 0.
    # v14: tempo_events (list of (at_tick, multiplier)) builds a piecewise
    # tempo track; actual_bpm is then ignored (basicTempo comes from the
    # segment model) and the first event MUST be (0, base_multiplier).
    if tempo_events is not None:
        events = list(tempo_events)
        if not events or events[0][0] != 0:
            raise ValueError("tempo track must start at tick 0")
        if actual_bpm <= 0:
            raise ValueError("actual BPM must be positive")
        basic_tempo = actual_bpm / tempo_multiplier
        for _, mm in events:
            if not (0.01 <= mm <= 10.0):
                raise ValueError("tempo multiplier must be in 0.01..10.0")
        return (cstr("Tempo", 15) +
                struct.pack("<fH", basic_tempo, len(events)) +
                b"".join(struct.pack("<Hf", min(int(t), 0xFFFF), float(mm))
                         for t, mm in events))
    if actual_bpm <= 0:
        raise ValueError("actual BPM must be positive")
    if not (0.01 <= tempo_multiplier <= 10.0):
        raise ValueError("tempo multiplier must be in 0.01..10.0")
    basic_tempo = actual_bpm / tempo_multiplier
    return (cstr("Tempo", 15) +
            struct.pack("<fH", basic_tempo, 1) +
            struct.pack("<Hf", 0, tempo_multiplier))


def voice_track(ch: int, notes):
    out = bytearray(cstr(f"Voix  {ch}", 15))
    total = sum(d for _, d in notes)
    out += struct.pack("<H", min(total, 0xFFFF))
    for note, dur in notes:
        out += struct.pack("<HH", note, dur)
    return bytes(out)


def timbre_track(ch: int, events):
    out = bytearray(cstr(f"Timbre {ch}", 15))
    out += struct.pack("<H", len(events))
    for tick, name, number in events:
        out += struct.pack("<H", min(tick, 0xFFFF))
        out += cstr(name, 9)
        out += b"\0"
        # The minimal known sample uses zero here.
        out += struct.pack("<H", 0)
    return bytes(out)


def volume_track(ch: int, events):
    out = bytearray(cstr(f"Volume {ch}", 15))
    out += struct.pack("<H", len(events))
    for tick, val in events:
        out += struct.pack("<Hf", min(tick, 0xFFFF), val)
    return bytes(out)


def pitch_track(ch: int, events):
    out = bytearray(cstr(f"Pitch  {ch}", 15))
    out += struct.pack("<H", len(events))
    for tick, val in events:
        out += struct.pack("<Hf", min(tick, 0xFFFF), val)
    return bytes(out)


def build_rol(rix, rec, bpm: float, tick_beat: int, beat_measure: int, tempo_multiplier: float, tempo_events=None):
    # Header fields confirmed by the known ROL sample:
    # version 0.4, tickBeat=4, beatMeasure=4,
    # scaleY=48, scaleX=56, reserved=0.
    header = bytearray()
    header += struct.pack("<HH", 0, 4)
    header += cstr(r"\roll\default", 40)
    header += struct.pack(
        "<HHHHBB",
        tick_beat,
        beat_measure,
        48,  # scaleY
        56,  # scaleX
        0,   # reserved
        1 if rix["mode"] == 0 else 0,  # melodic
    )

    # 45 counters:
    # 11 cTicks, 11 timbre counts, 11 volume counts, 11 pitch counts,
    # 1 tempo event count.
    for ch in range(11):
        total = sum(d for _, d in rec["notes"][ch])
        header += struct.pack("<H", min(total, 0xFFFF))
    for ch in range(11):
        header += struct.pack("<H", len(rec["timbre"][ch]))
    for ch in range(11):
        header += struct.pack("<H", len(rec["volume"][ch]))
    for ch in range(11):
        header += struct.pack("<H", len(rec["pitch"][ch]))
    header += struct.pack("<H", len(tempo_events) if tempo_events else 1)

    header += bytes(38)

    assert len(header) == 182, len(header)

    tracks = [tempo_track(bpm, tempo_multiplier, tempo_events=tempo_events)]
    for ch in range(11):
        tracks += [
            voice_track(ch, rec["notes"][ch]),
            timbre_track(ch, rec["timbre"][ch]),
            volume_track(ch, rec["volume"][ch]),
            pitch_track(ch, rec["pitch"][ch]),
        ]

    assert len(tracks) == 45
    return bytes(header) + b"".join(tracks)


def write_report(path: Path, rix, rec, bpm, tick_beat, tempo_multiplier, segments=None):
    with path.open("w", encoding="utf-8") as f:
        f.write("RIX -> ROL reconstruction report (noteSelect timeline reconstruction)\n")
        f.write("=" * 60 + "\n")
        f.write(f"RIX duration units: {rix['duration_rix']}\n")
        f.write(f"Actual BPM: {bpm}\n")
        f.write(f"Tempo multiplier: {tempo_multiplier}\n")
        f.write(f"Basic Tempo written to ROL: {bpm / tempo_multiplier:.9f}\n")
        if segments:
            model = segments["model"]
            if model is None:
                f.write("Tempo-map build: single-tempo local fit "
                        "(no reliable change point)\n")
                for i, s in enumerate(segments["segs"]):
                    f.write(f"  seg{i}: u0={s['u0']:6d} "
                            f"bpm={s['bpm']:.9f} "
                            f"rms={s['rms']:.6f} n={len(s['rpts'])}\n")
            else:
                f.write(f"Tempo-map build: {len(segments['segs'])} segments, "
                        f"scale x{model['scale']}\n")
                for i, s in enumerate(segments["segs"]):
                    f.write(f"  seg{i}: u0={s['u0']:6d} "
                            f"tick0={model['bounds'][i]:6d} "
                            f"bpm={model['beat_bpms'][i]:.9f} "
                            f"(grid bpm {model['bpms'][i]:.9f}) "
                            f"mult={model['mults'][i]:.6f} "
                            f"rms={s['rms']:.6f} n={len(s['rpts'])}\n")
        f.write(f"tickBeat: {tick_beat}\n")
        f.write(f"ROL ticks/sec: {rec['ticks_per_second']:.9f}\n")
        f.write(f"ROL duration ticks: {rec['end_tick']}\n")
        f.write(
            f"ROL nominal duration: "
            f"{rec['end_tick']/rec['ticks_per_second']:.6f} sec\n"
        )
        f.write(f"RIX instruments: {rix['instruments']}\n")
        f.write("\n")

        for ch in range(11):
            if not (rec["notes"][ch] or rec["timbre"][ch] or
                    rec["volume"][ch] or rec["pitch"][ch]):
                continue
            f.write(f"Channel {ch}\n")
            f.write(f"  notes:   {rec['notes'][ch]}\n")
            f.write(f"  timbre:  {rec['timbre'][ch]}\n")
            f.write(f"  volume:  {rec['volume'][ch]}\n")
            f.write(f"  pitch:   {rec['pitch'][ch]}\n")
            f.write("\n")

def rix_note_events(rix):
    """Return the same collapsed Cx timeline used by reconstruct()."""
    out = [[] for _ in range(11)]
    for e in rix["events"]:
        if e.channel >= 11 or e.typ not in ("note", "off"):
            continue
        value = e.value if e.typ == "note" else 0
        if out[e.channel] and out[e.channel][-1][0] == e.time_rix:
            out[e.channel][-1] = (e.time_rix, value)
        else:
            out[e.channel].append((e.time_rix, value))
    return out


def match_bpm(rix, rol, bpm: float):
    """Compare RIX note-select positions against a reference ROL."""
    tick_rate = bpm / 60.0 * rol["tick_beat"]
    rr = rix_note_events(rix)
    ref = reference_note_starts(rol)
    exact = 0
    total = 0
    errors = []
    mismatched_channels = []

    for ch in range(11):
        if len(rr[ch]) != len(ref[ch]):
            mismatched_channels.append((ch, len(rr[ch]), len(ref[ch])))
        n = min(len(rr[ch]), len(ref[ch]))
        for i in range(n):
            time_ms, note = rr[ch][i]
            ref_tick, ref_note = ref[ch][i]
            predicted = int(math.floor(time_ms * tick_rate / 1000.0 + 0.5))
            error = ref_tick - predicted
            errors.append(error)
            total += 1
            if predicted == ref_tick and note == ref_note:
                exact += 1

    if errors:
        rms = math.sqrt(sum(e * e for e in errors) / len(errors))
        max_abs = max(abs(e) for e in errors)
        jumps = [abs(errors[i] - errors[i-1]) for i in range(1, len(errors))]
        max_jump = max(jumps, default=0)
        large_jumps = sum(1 for j in jumps if j > 1.0)
    else:
        rms = max_abs = max_jump = 0.0
        large_jumps = 0

    return {
        "bpm": bpm,
        "exact": exact,
        "total": total,
        "ratio": exact / total if total else 0.0,
        "rms": rms,
        "max_abs": max_abs,
        "max_jump": max_jump,
        "large_jumps": large_jumps,
        "mismatched_channels": mismatched_channels,
    }


def scan_bpm(rix, rol, bpm_min: float, bpm_max: float, step: float):
    if step <= 0 or bpm_max < bpm_min:
        raise ValueError("invalid BPM scan range")
    results = []
    bpm = bpm_min
    # Integer-index stepping avoids accumulating floating-point step error.
    count = int(math.floor((bpm_max - bpm_min) / step + 1e-9))
    for i in range(count + 1):
        b = bpm_min + i * step
        results.append(match_bpm(rix, rol, b))
    results.sort(key=lambda x: (-x["exact"], x["rms"], x["max_abs"], x["max_jump"], abs(x["bpm"])))
    return results


def print_match_report(results, limit=20):
    print("BPM matching results (sorted by exact matches, RMS, max error, max jump):")
    print("  BPM         exact/total    match%       RMS      maxErr   maxJump  jumps>1")
    for r in results[:limit]:
        print(f"  {r['bpm']:9.4f}  {r['exact']:5d}/{r['total']:<5d}  "
              f"{r['ratio']*100:8.3f}%  {r['rms']:8.4f}  "
              f"{r['max_abs']:7.3f}  {r['max_jump']:7.3f}  {r['large_jumps']:7d}")


def bpm_tick_fit(rix, bpm: float, tick_beat: int):
    """
    Estimate how naturally the RIX absolute event positions fit an integer
    ROL-tick grid at this BPM.

    This is intentionally independent of any reference ROL.  For every
    note-select event we calculate the continuous tick position and measure
    its distance from the nearest integer tick.  We also measure whether that
    quantization error drifts systematically with song time.

    A BPM is considered especially good when:
      * the integer tick sequence is stable (nearby BPMs give the same ticks),
      * fractional quantization error is small, and
      * the error has essentially no linear drift over time.
    """
    c = tick_beat / float(60 * RIX_UNITS_PER_SEC)
    rate = bpm * c
    points = []
    for ch, evs in enumerate(rix_note_events(rix)):
        for rix_pos, note in evs:
            x = rix_pos * rate
            tick = int(math.floor(x + 0.5))
            err = tick - x
            points.append((rix_pos, ch, tick, err))

    if not points:
        return {
            "bpm": bpm, "events": 0, "rms": 0.0, "mean_abs": 0.0,
            "max_abs": 0.0, "drift": 0.0, "sequence": (),
            "total_ticks": 0, "ticks": ()
        }

    # Sort globally by absolute RIX time.  The tick sequence is what the
    # final ROL will actually contain, after channel-local ordering.
    points.sort(key=lambda p: (p[0], p[1]))

    errs = [p[3] for p in points]
    times = [p[0] for p in points]
    mean = sum(errs) / len(errs)
    rms = math.sqrt(sum(e * e for e in errs) / len(errs))
    mean_abs = sum(abs(e) for e in errs) / len(errs)
    max_abs = max(abs(e) for e in errs)

    # Least-squares slope of quantization error versus absolute RIX time.
    mt = sum(times) / len(times)
    me = mean
    den = sum((t - mt) ** 2 for t in times)
    drift = (sum((t - mt) * (e - me) for t, e in zip(times, errs)) / den
             if den else 0.0)

    # Build the actual channel-local integer tick sequence.  This lets us
    # detect plateaus: several BPM values may produce exactly the same ROL.
    seq = tuple((ch, tick, note)
                for ch, evs in enumerate(rix_note_events(rix))
                for rix_pos, note in evs
                for tick in [int(math.floor(rix_pos * rate + 0.5))])

    return {
        "bpm": bpm,
        "events": len(points),
        "rms": rms,
        "mean_abs": mean_abs,
        "max_abs": max_abs,
        "drift": abs(drift),
        "sequence": seq,
        "total_ticks": max(p[2] for p in points),
        "ticks": tuple(p[2] for p in points),
    }


# ---------------------------------------------------------------------------
# v14: tempo-map detection (multi-tempo RIX guard)
# ---------------------------------------------------------------------------
#
# A single-tempo song -- even one that NO single BPM quantizes cleanly
# (MUS5's 124/125ms pair, MUS17's dotted grids, MUS27's grace notes) -- has
# local BPM estimates that mutually agree: octave-folded sliding-window fits
# cluster within ~1%.  A song the composer actually re-tempoed mid-piece
# (MUS61: phrase periods 295/263/238/109ms) makes the window estimates
# TRAVEL: folded estimates spread over tens of BPM.  Discriminator =
# median-absolute-deviation of folded local fits.  Calibration over the
# 87-file corpus: MUS61 mad 0.169 (the only file > 0.02); worst non-map
# file 0.0031 -> 6x threshold margin at mad_gate=0.02.
def _octave_down(points, tick_beat, b, r):
    """Return (bpm, rmsfrac) with a fitted bpm above 200 halved when the
    exact /2 reading is no worse under the same objective."""
    if b <= 200.0 or not points:
        return b, r
    k = tick_beat / float(60 * RIX_UNITS_PER_SEC)
    half = b / 2.0
    s = 0.0
    for u in points:
        x = k * half * u
        e = x - math.floor(x + 0.5)
        s += e * e
    r2 = math.sqrt(s / len(points))
    if r2 <= r:
        if os.environ.get("RIX_DEBUG_OCTAVE"):
            print(f"[octave] {b:.6f} -> {half:.6f} "
                  f"(rms {r:.6f} -> {r2:.6f})", file=sys.stderr)
        return half, r2
    return b, r


def local_onset_fit(points, tick_beat, lo=10.0, hi=250.0, coarse=0.5):
    """Best single-BPM tick-grid fit for ONE window of absolute onsets.
    Coarse sweep + analytic plateau-vertex polish (same solver class as the
    global v13 descent, just on a subset).  Returns (bpm, rmsfrac)."""
    k = tick_beat / float(60 * RIX_UNITS_PER_SEC)
    n = len(points)
    if n < 2:
        return lo, 0.0
    # A fit that does not spread the window over at least 1.5 ticks is
    # degenerate (everything on one tick): its rms is meaningless noise.
    span = points[-1] - points[0]
    if span > 0:
        lo = max(lo, 1.5 * 60 * RIX_UNITS_PER_SEC / (tick_beat * span))
    best_b, best_r, b = lo, 9e9, lo
    while b <= hi:
        s = 0.0
        for u in points:
            x = k * b * u
            e = x - math.floor(x + 0.5)
            s += e * e
        r = math.sqrt(s / n)
        if r < best_r:
            best_b, best_r = b, r
        b += coarse
    ticks = tuple(int(math.floor(k * best_b * u + 0.5)) for u in points)
    cell_lo, cell_hi, vertex = plateau_bounds(points, ticks, tick_beat)
    if vertex is not None and vertex > 0 and \
            cell_lo <= Fraction(best_b) <= cell_hi:
        s = 0.0
        for u in points:
            x = k * float(vertex) * u
            e = x - math.floor(x + 0.5)
            s += e * e
        r = math.sqrt(s / n)
        if r <= best_r:
            best_b, best_r = float(vertex), r
    # Simple octave hack: the sweep is capped at hi=250 and the span rule can
    # even raise lo above 200 on a short piece, so a fitted minimum above 200
    # is often the same grid read one octave high.  Test the exact /2
    # candidate against this same objective and keep it when it is no worse.
    return _octave_down(points, tick_beat, best_b, best_r)


def _fold_tempo(b, lo=50.0, hi=100.0):
    while b >= hi:
        b /= 2.0
    while b < lo:
        b *= 2.0
    return b


def _octave_align(b, ref):
    """Fold b into (0.75, 1.5]*ref -- octave/double stops are the SAME
    tempo for segmentation purposes (MUS17: 52.44/104.92/157.38 windows)."""
    if b <= 0 or ref <= 0:
        return ref
    while b < 0.75 * ref:
        b *= 2.0
    while b > 1.5 * ref:
        b /= 2.0
    return b


def detect_tempo_map(rix, tick_beat=4, mad_gate=0.02, rms_gate=0.10,
                     min_windows=8):
    """
    Classify a RIX as single-tempo vs tempo-map.  Ambiguity resolves toward
    'single' on every bail-out path (few onsets, few good windows): the
    detector only ever ADDS a hint (default mode) or gates an opt-in build
    (--tempo-map); it never rewrites v13 results.
    """
    positions = sorted(set(rix_note_positions(rix)))
    n = len(positions)
    if n < 20:
        return {"verdict": "single", "why": "few onsets", "n_onsets": n,
                "mad": None}
    W = max(6, min(12, n // 5))
    S = max(2, W // 3)
    folded = []
    i = 0
    while i + W <= n:
        b, r = local_onset_fit(positions[i:i + W], tick_beat)
        if r < rms_gate:
            folded.append(_fold_tempo(b))
        i += S
    if len(folded) < min_windows:
        return {"verdict": "single", "why": "few good windows",
                "n_onsets": n, "n_windows": len(folded), "mad": None}
    fs = sorted(folded)
    mu = fs[len(fs) // 2]
    mad = sorted(abs(x - mu) for x in folded)[len(folded) // 2]
    ratio = mad / mu
    return {"verdict": "tempo-map" if ratio > mad_gate else "single",
            "mad": ratio, "center_bpm": mu, "n_onsets": n,
            "n_windows": len(folded)}


def fit_single_segment(rix, tick_beat=4, coarse=0.05):
    """Whole-piece single-tempo fit using the SAME local fitter that the
    tempo-map segments use.

    fit_tempo_segments() returns [] whenever the phrase structure offers no
    convincing change point -- which is the normal case for a piece that
    really is single-tempo.  Without this, --tempo-map dies with "no
    reliable tempo-change boundaries ... supply --bpm", so the local-fit
    method could only ever be applied to multi-segment pieces.  Fitting the
    whole piece with the same fitter makes the method applicable
    unconditionally.

    Returns a segment-shaped dict (u0 == 0), or None when there is nothing
    to fit.
    """
    pos = sorted(set(rix_note_positions(rix)))
    if len(pos) < 2:
        return None
    b, r = local_onset_fit(pos, tick_beat, coarse=coarse)
    return {"u0": 0, "bpm": b, "rms": r, "rpts": pos}


def fit_tempo_segments(rix, tick_beat=4, run_tol=0.04, min_run=2):
    """
    Split a (confirmed or user-declared) tempo-map RIX into constant-tempo
    segments along PHRASE-PERIOD runs.  Grace-note pairs (a <=40ms echo
    behind an onset, MUS61: 25/22/20/18/17ms shrinking with the accelerando)
    are collapsed greedily; the surviving phrase-to-phrase gaps are the
    periods the composer wrote (MUS61: 295,295,295,295 | 263,263,263 |
    238,238,238,238 | 109 | 54 | 50).  A run-length encoding with tolerance
    run_tol finds the change points; a change only counts when BOTH
    neighbouring runs are at least min_run gaps long (one stray gap is a
    notation detail, not a new tempo).  Every segment is then fit EXACTLY
    over its own onsets, RELATIVE to the segment start: in a piecewise build
    the tempo change re-phases the grid (each segment starts on a whole
    tick), so absolute-onset phase must not leak across a boundary.
    Returns [{"u0","bpm","rms","rpts"}, ...], first u0 == 0, or [] when the
    gap structure offers no convincing change point.
    """
    pos = sorted(set(rix_note_positions(rix)))
    n = len(pos)
    if n < 12:
        return []
    # greedy phrase starts: an onset <=40 units after the current phrase
    # head is its echo, not a new beat
    ph = [pos[0]]
    for p in pos[1:]:
        if p - ph[-1] > 40:
            ph.append(p)
    if len(ph) < 2 * min_run + 2:
        return []
    gaps = [ph[i + 1] - ph[i] for i in range(len(ph) - 1)]
    runs = []
    i = 0
    while i < len(gaps):
        j = i + 1
        while j < len(gaps) and abs(gaps[j] - gaps[i]) <= \
                run_tol * min(gaps[i], gaps[j]):
            j += 1
        gg = sorted(gaps[i:j])
        runs.append((i, j, gg[len(gg) // 2]))
        i = j
    bounds = [0]
    for a in range(len(runs) - 1):
        i0, i1, p0 = runs[a]
        j0, j1, p1 = runs[a + 1]
        if i1 - i0 < min_run or j1 - j0 < min_run:
            continue
        if abs(p1 - p0) / min(p0, p1) <= run_tol:
            continue
        u = ph[i1]                # first onset of the new period run
        if u > bounds[-1]:
            bounds.append(u)
    if len(bounds) < 2:
        return []
    # A boundary is only usable when the segment it closes still has enough
    # onsets to fit (the loop below needs >= 3).  Discarding the FIRST segment
    # would leave the list starting at u0 != 0, which build_segment_model()
    # rejects ("segments must start at u0 == 0", hit by MUS52/MUS73), so a
    # short leading stub is merged into its successor rather than dropped.
    keep = [0]
    for u in bounds[1:]:
        if sum(1 for p in pos if keep[-1] <= p < u) >= 3:
            keep.append(u)
    bounds = keep
    if len(bounds) < 2:
        return []
    out = []
    for bi, u0 in enumerate(bounds):
        u1 = bounds[bi + 1] if bi + 1 < len(bounds) else None
        pts = [p - u0 for p in pos if p >= u0 and (u1 is None or p < u1)]
        # fit on PHRASE HEADS only: a grace-note echo sits a fixed ~17-25ms
        # behind its head, which no beat grid can place on whole ticks, so
        # including echoes biases the vertex and inflates rms (MUS61 tail:
        # 0.048 -> 0.18).  Reconstruction still maps every onset -- the echo
        # merely stops pulling the tempo.
        heads = [p - u0 for p in ph if p >= u0 and (u1 is None or p < u1)]
        if len(pts) < 3:
            continue
        # All onsets (heads + echoes): 4 heads alone alias freely (any gap
        # can become "1 tick" at some octave); the dense echo-anchored fit
        # is unambiguous.  heads stay in the dict for diagnostics only.
        b, r = local_onset_fit(pts, tick_beat, coarse=0.05)
        if out and abs(_octave_align(b, out[-1]['bpm']) - out[-1]['bpm']) \
                / out[-1]['bpm'] < 0.01:
            # tempo unchanged: fold this stub back into the previous segment
            prev = out[-1]
            hi_u = u1 if u1 is not None else 1 << 62
            allp = sorted(set(prev['rpts'])
                          | {p - prev['u0'] for p in pos if u0 <= p < hi_u})
            heads2 = sorted(set(prev.get('heads', prev['rpts']))
                            | {p - prev['u0'] for p in ph if u0 <= p < hi_u})
            b2, r2 = local_onset_fit(allp, tick_beat, coarse=0.05)
            out[-1] = {'u0': prev['u0'], 'bpm': b2, 'rms': r2,
                       'rpts': allp, 'heads': heads2}
            continue
        out.append({'u0': u0, 'bpm': b, 'rms': r, 'rpts': pts,
                    'heads': heads})
    return out


# ---------------------------------------------------------------------------
# v13: analytic plateau + recursive-descent (steepest-vertex) BPM refinement
# ---------------------------------------------------------------------------
#
# Math (all under the 1000 units/s clock):
#
#   x_i(b) = u_i * b * tickBeat / (60 * 1000)        continuous tick position
#   r(b)   = (1/N) * sum_i (round(x_i(b)) - x_i(b))^2   RMSfrac^2
#
# r(b) is continuous and piecewise quadratic.  Inside a "plateau" the rounded
# ticks t_i are all frozen; r is a strictly convex parabola there:
#
#   r(b) = (1/N) * sum_i (t_i - k*b*u_i)^2,  k = tickBeat/(60*1000)
#   vertex b* = sum_i t_i*u_i / (k * sum_i u_i^2)
#
# Each event u_i freezes ticks on
#   [ (2*t_i - 1) * 30*1000 / (u_i*tickBeat),
#     (2*t_i + 1) * 30*1000 / (u_i*tickBeat) )      (left closed, right open)
# so the plateau interval can be solved EXACTLY in rationals, no scan needed.
# The recursion: evaluate the parabola vertex; if it lies inside the current
# plateau it is that cell's bottom.  Then jump to whichever adjacent cell has
# the lower bottom (probing past a boundary into the neighbour's own vertex),
# because r's slope drops at every knot and a shallow cell can hide a deeper
# neighbour (MUS1: naive boundary probing stalls at 119.985 instead of the
# true 120.044).  Every accepted move strictly lowers r; cell bottoms are
# finitely many, so the walk terminates at the basin's true minimum.  The
# walk restarts from every coarse local dip (below the 1/sqrt(12) uniform
# quantization noise floor) so a well narrower than --scan-step, which the
# fixed grid only sees as a shoulder, is still descended into exactly.


def _frac(x) -> Fraction:
    return x if isinstance(x, Fraction) else Fraction(x)


def rix_note_positions(rix):
    """Absolute RIX positions of every note-select event, sorted, with dupes."""
    return sorted(u for evs in rix_note_events(rix) for u, _n in evs)


def plateau_bounds(positions, ticks, tick_beat):
    """
    Exact plateau [lo, hi): the maximal interval on which every event keeps
    its current integer tick.  Computed in rationals.

    Returns (lo, hi, vertex) as Fractions, where vertex = parabola minimizer
    of r(b) under frozen ticks (may be None for degenerate input).
    """
    tb = tick_beat
    lo = Fraction(0, 1)
    hi = None
    sum_tu = 0
    sum_uu = 0
    k_num, k_den = tb, 60 * RIX_UNITS_PER_SEC   # x = b * k_num/den * u
    for u, t in zip(positions, ticks):
        if u == 0:
            continue
        # b such that x = t - 1/2  ->  b = (2t - 1) * 60*1000 / (2*u*tb)
        left = Fraction((2 * t - 1) * 30 * RIX_UNITS_PER_SEC, u * tb)
        right = Fraction((2 * t + 1) * 30 * RIX_UNITS_PER_SEC, u * tb)
        if left > lo:
            lo = left
        if hi is None or right < hi:
            hi = right
        sum_tu += t * u
        sum_uu += u * u
    if hi is None:
        hi = lo + 1  # degenerate: only zero-position events
    vertex = (Fraction(sum_tu, 1) * Fraction(k_den, k_num * sum_uu)
              if sum_uu else None)
    return lo, hi, vertex


def refine_rms_minimum(rix, center_bpm: float, tick_beat: int,
                       radius: float, step: float,
                       max_iter: int = 60, tol_bpm: float = 1e-9):
    """
    Find the true minimum of RMSfrac over [center-radius, center+radius]
    by recursive plateau-vertex descent, seeded from the fixed coarse scan.

    Returns (coarse_results, refined_best, window).  refined_best has the same
    dict shape as bpm_tick_fit() plus "plateau": (lo, hi) exact Fractions of
    the FINAL plateau (the maximal interval sharing its tick sequence), and
    "coarse_rms"/"coarse_bpm"/"seeds" bookkeeping for the report.
    """
    positions = rix_note_positions(rix)
    if not positions:
        return [], None, None

    A = max(Fraction(1, 1000000), _frac(center_bpm - radius))
    B = _frac(center_bpm + radius)

    def clamp(b):
        return min(max(b, A), B)

    def fit_at(b):
        return bpm_tick_fit(rix, float(b), tick_beat)

    # Coarse pass: identical to the v12 fixed-resolution scan.  It is both the
    # report table and the seed set; it may miss a minimum that lives in a
    # narrow spike between grid points -- the descent below fixes that.
    results = []
    n = int(round(2 * radius / step))
    for i in range(n + 1):
        b = _frac(center_bpm - radius) + i * _frac(step)
        if A <= b <= B:
            results.append(fit_at(b))
    if not results:
        return results, None, None

    ranked = sorted(results, key=lambda r: (r["rms"], r["drift"],
                                            r["max_abs"],
                                            abs(r["bpm"] - center_bpm)))
    seed0 = ranked[0]

    # Descend from every coarse local minimum (a grid dip not worse than both
    # neighbours) that dips clearly below the uniform-quantization noise floor
    # 1/sqrt(12) ~ 0.2887, plus the global coarse best as guaranteed fallback.
    # A narrow deep well whose plateau is thinner than --scan-step shows up in
    # the grid only as such shoulders; fixed-resolution scans stall there, the
    # vertex descent finds its true bottom.  Dedup by tick family, cap at 64
    # basins so a pathological window stays fast.
    thr = 0.98 / math.sqrt(12.0)
    seeds = []
    seen = set()
    for idx, r in enumerate(results):
        if r["rms"] >= thr and r is not seed0:
            continue
        left_ok = idx == 0 or results[idx - 1]["rms"] >= r["rms"]
        right_ok = (idx == len(results) - 1
                    or results[idx + 1]["rms"] >= r["rms"])
        if left_ok and right_ok and r["ticks"] not in seen:
            seen.add(r["ticks"])
            seeds.append(r)
    if seed0["ticks"] not in seen:
        seeds.insert(0, seed0)
    seeds.sort(key=lambda r: r["rms"])
    seeds = seeds[:64]

    best = None
    for s in seeds:
        cur = s
        b = clamp(_frac(cur["bpm"]))
        local_best = cur
        for _ in range(max_iter):
            lo, hi, vertex = plateau_bounds(positions, cur["ticks"],
                                            tick_beat)
            L = max(lo, A)
            R = min(hi, B)
            if R - L <= 0:
                break
            cands = [b, L, R]
            if vertex is not None and L <= vertex <= R:
                cands.append(vertex)
            scored = []
            for c in cands:
                f = cur if c == b else fit_at(c)
                scored.append((f["rms"], f["drift"], f["max_abs"], c, f))
            scored.sort(key=lambda z: z[:3])
            if scored[0][3] == b:
                # Bottom of this cell reached.  A neighbouring cell can still
                # be deeper: r's slope jumps DOWN at every knot, so our bottom
                # can sit near the rim of a shallow basin while the adjacent
                # cell's bottom lies lower -- its SHOULDER (any naive probe
                # point) is higher than our bottom, so probing shoulders alone
                # stalls (found on MUS1: 119.985368 vs true 120.044298).
                # Therefore evaluate neighbour bottoms directly: step past a
                # boundary, jump into that cell's own vertex, walk there only
                # if strictly better (bottoms strictly decrease => no cycles,
                # finite cells => termination).
                w = (R - L) if R > L else Fraction(1, 1000)
                probes = []
                for c in (L - w / 2, L - w / 4, R + w / 4, R + w / 2):
                    c = clamp(c)
                    if c != b and c not in probes:
                        probes.append(c)
                improved = None
                cur_key = (cur["rms"], cur["drift"], cur["max_abs"])
                for c in probes:
                    f = fit_at(c)
                    lo2, hi2, v2 = plateau_bounds(positions, f["ticks"],
                                                  tick_beat)
                    if v2 is not None:
                        L2 = max(lo2, A)
                        R2 = min(hi2, B)
                        if L2 <= v2 <= R2:
                            c, f = v2, fit_at(v2)
                    f_key = (f["rms"], f["drift"], f["max_abs"])
                    if f_key < cur_key and (improved is None
                                            or f_key < improved[2]):
                        improved = (c, f, f_key)
                if improved is None:
                    break
                b, cur = improved[0], improved[1]
            else:
                _, _, _, b, cur = scored[0]
            if (cur["rms"], cur["drift"], cur["max_abs"]) < \
               (local_best["rms"], local_best["drift"], local_best["max_abs"]):
                local_best = cur
            if R - L <= tol_bpm:
                break
        if best is None or (local_best["rms"], local_best["drift"],
                            local_best["max_abs"]) < \
           (best["rms"], best["drift"], best["max_abs"]):
            best = local_best

    # Final analytic plateau of the refined optimum.
    lo, hi, _v = plateau_bounds(positions, best["ticks"], tick_beat)
    best = dict(best)
    best["plateau"] = (lo, hi)
    best["coarse_rms"] = seed0["rms"]
    best["coarse_bpm"] = seed0["bpm"]
    best["seeds"] = len(seeds)
    return results, best, (A, B)


def select_from_plateau(best, rix, tick_beat):
    """
    Canonical output BPM for the refined optimum.

    v11/v12 had no exact minimizer, so they cosmetically preferred the
    plateau member nearest to the user's center BPM.  v13 does have one:
    inside a plateau every BPM yields the IDENTICAL integer tick sequence,
    so the vertex (the RMS minimizer) is the strictly better representative
    -- it centers all quantization residuals at ~0 and maximizes the margin
    to any tick flip.  The nearest-to-center cosmetic remains available
    through the exact v11/v12 path via --no-refine.

    Re-fit the vertex in double-precision arithmetic; if rounding survives
    (ticks unchanged) use it, else fall back to the plateau midpoint, else
    keep the descent point.
    """
    lo, hi = best["plateau"]
    cand = bpm_tick_fit(rix, float(best["bpm"]), tick_beat)
    if cand["ticks"] == best["ticks"]:
        cand["plateau"] = (lo, hi)
        cand["coarse_rms"] = best["coarse_rms"]
        cand["coarse_bpm"] = best["coarse_bpm"]
        return cand, lo, hi
    mid = (lo + hi) / 2
    alt = bpm_tick_fit(rix, float(mid), tick_beat)
    if alt["ticks"] == best["ticks"]:
        alt["plateau"] = (lo, hi)
        alt["coarse_rms"] = best["coarse_rms"]
        alt["coarse_bpm"] = best["coarse_bpm"]
        return alt, lo, hi
    return best, lo, hi


def scan_bpm_intrinsic(rix, center_bpm: float, tick_beat: int,
                       radius: float = 1.0, step: float = 0.1,
                       refine: bool = True):
    """
    Scan BPM around the user's measured value without using a reference ROL.

    Stage 1 (coarse): fixed-step grid, reported as a table.
    Stage 2 (v13, refine=True): recursive plateau-vertex descent to the exact
    minimum of RMSfrac -- resolution-independent, no shrinking-step loop that
    can stall between grid points.
    Stage 3: `selected` = the exact minimizer of RMSfrac.  All members of its
    plateau generate the identical integer tick sequence, so stage 3 never
    changes the output ROL timing, only the literal Basic Tempo value that
    gets written.  With refine=False stages 2/3 collapse to the exact
    v11/v12 behaviour (grid best + nearest-to-center plateau member).
    """
    if center_bpm <= 0 or radius < 0 or step <= 0:
        raise ValueError("invalid BPM scan parameters")

    if not refine:
        results = []
        n = int(round(2 * radius / step))
        for i in range(n + 1):
            b = center_bpm - radius + i * step
            results.append(bpm_tick_fit(rix, b, tick_beat))
        best = min(results, key=lambda r: (r["rms"], r["drift"],
                                           r["max_abs"],
                                           abs(r["bpm"] - center_bpm)))
        plateau = [r for r in results if r["sequence"] == best["sequence"]]
        selected = min(plateau, key=lambda r: abs(r["bpm"] - center_bpm))
        return results, best, plateau, selected

    results, best, window = refine_rms_minimum(rix, center_bpm, tick_beat,
                                               radius, step)
    if best is None:
        return [], None, [], None
    selected, sel_lo, sel_hi = select_from_plateau(best, rix, tick_beat)
    return results, best, (sel_lo, sel_hi), selected


def print_intrinsic_report(results, best, plateau, selected, refine=True):
    print("\nIntrinsic BPM scan (no reference ROL):")
    print("  BPM       RMSfrac    MeanAbs    MaxAbs     Drift      TotalTicks")
    for r in results:
        mark = " "
        if refine:
            if best is not None:
                lo, hi = best["plateau"]
                fr = Fraction(r["bpm"])
                if lo <= fr < hi:
                    mark = "="   # inside the refined optimum's exact plateau
                if best["coarse_bpm"] is not None and \
                   r["bpm"] == best["coarse_bpm"]:
                    mark = "C"   # coarse scan best: seed of the descent
        else:
            mark = "*" if r is selected else " "
        print(f"{mark} {r['bpm']:7.2f}   {r['rms']:8.5f}  "
              f"{r['mean_abs']:8.5f}  {r['max_abs']:8.5f}  "
              f"{r['drift']:10.3e}  {r['total_ticks']:9d}")

    if refine and best is not None:
        print("\nCoarse scan best (grid seed):")
        print(f"  BPM: {best['coarse_bpm']:.2f}   "
              f"RMSfrac: {best['coarse_rms']:.6f}")
        print("\nRefined minimum (plateau-vertex descent, "
              f"{best.get('seeds', '?')} basin seeds):")
        print(f"  BPM: {best['bpm']:.9f}")
        print(f"  RMS fractional-tick error: {best['rms']:.9f}")
        print(f"  Max fractional-tick error: {best['max_abs']:.6f}")
        lo, hi = plateau
        print(f"  Exact BPM plateau: "
              f"[{float(lo):.6f}, {float(hi):.6f})  "
              f"width {float(hi - lo):.6f} BPM")
        print(f"  Selected BPM for output: {selected['bpm']:.9f}  "
              f"(RMSfrac {selected['rms']:.6f})")
        print("  (rows '=': coarse grid points inside the exact plateau; "
              "'C': grid seed)")
    elif best is not None:
        print("\nBest intrinsic grid fit:")
        print(f"  BPM: {best['bpm']:.2f}")
        print(f"  RMS fractional-tick error: {best['rms']:.6f}")
        print(f"  Max fractional-tick error: {best['max_abs']:.6f}")
        if plateau:
            print(f"  Equivalent BPM plateau: "
                  f"{plateau[0]['bpm']:.2f} .. {plateau[-1]['bpm']:.2f} "
                  f"({len(plateau)} scanned values)")
        print(f"  Selected BPM for output: {selected['bpm']:.2f}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rix", type=Path)
    ap.add_argument("--bpm", type=float,
                    help="Actual/heard playback BPM; scan around it and select the best tick-grid fit")
    ap.add_argument("--scan-radius", type=float, default=3.0,
                    help="Intrinsic BPM scan radius around --bpm (default: 3.0)")
    ap.add_argument("--scan-step", type=float, default=0.1,
                    help="Intrinsic BPM coarse-scan step (default: 0.1)")
    ap.add_argument("--no-refine", action="store_true",
                    help="Disable v13 recursive-descent refinement; report the "
                         "fixed-grid result exactly as v11/v12 did")
    ap.add_argument("--tempo-map", action="store_true",
                    help="v14: build this RIX as a multi-tempo piece: fit "
                         "constant-tempo segments and write a piecewise ROL "
                         "tempo track.  Without it the v13 single-tempo path "
                         "runs unchanged (a hint is printed if the piece "
                         "looks re-tempoed mid-song).")
    ap.add_argument("--tempo-multiplier", type=float, default=1.0,
                    help="ROL tempo multiplier to preserve (default: 1.0)")
    ap.add_argument("--top", type=int, default=20,
                    help="Number of best BPM matches to print")
    ap.add_argument("--tick-beat", type=int, default=4,
                    help="ROL ticks per beat (known sample: 4)")
    ap.add_argument("--beat-measure", type=int, default=4)
    ap.add_argument("--out", type=Path)
    ap.add_argument("--bnk", type=Path)
    ap.add_argument("--report", type=Path)
    ap.add_argument("--adplay", action="store_true",
                    help="After writing the ROL, play it with "
                         "'adplay -O sdl <rol>'")
    ap.add_argument("--no-build", action="store_true",
                    help="Only run BPM matching; do not write ROL/BNK")
    args = ap.parse_args()

    rix = read_rix(args.rix)

    # v14: tempo-map analysis.  Detection is cheap and side-effect free; it
    # only ever adds an advisory (off) or gates the map build (on).
    detection = None
    map_model = None
    map_segments = None
    single_fit = None
    if args.bpm is not None or args.tempo_map:
        detection = detect_tempo_map(rix, args.tick_beat)

    if args.tempo_map:
        segs = fit_tempo_segments(rix, args.tick_beat)
        if len(segs) >= 2:
            hint = args.bpm
            if hint is None and detection and detection.get("center_bpm"):
                hint = detection["center_bpm"]
            basic, base_tps, map_model = build_segment_model(
                args.tempo_multiplier, args.tick_beat, segs,
                rix["duration_rix"], base_bpm_hint=hint)
            map_segments = {"segs": segs, "model": map_model}
            print("\nTempo-map build (v14 --tempo-map):")
            if detection is not None:
                print("  detector: " + (
                    f"tempo-map (mad {detection['mad']:.4f})"
                    if detection["verdict"] == "tempo-map" else
                    f"{detection['verdict']} ({detection.get('why', 'ok')})"))
            for i, s in enumerate(segs):
                print(f"  seg{i}: u0={s['u0']:6d} "
                      f"({s['u0'] / 1000.0:7.3f}s) "
                      f"tick0={map_model['bounds'][i]:6d}  "
                      f"bpm={map_model['beat_bpms'][i]:10.6f}  "
                      f"mult={map_model['mults'][i]:.6f}  "
                      f"rms={s['rms']:.6f}  n={len(s['rpts'])}")
            print(f"  grid scale x{map_model['scale']} (grace-note gaps "
                  f"must fill >= 1 tick; playback unchanged)")
            bb = map_model["beat_bpms"]
            print(f"  played beat-level: {min(bb):.1f} .. {max(bb):.1f} BPM")
            if map_model["collisions"]:
                print("  NOTE: sub-tick onset gaps (co-landed) in segments "
                      + ", ".join(str(i) for i in map_model["collisions"]))
            print(f"  written track: basicTempo {basic:.6f} with "
                  f"{len(map_model['mults'])} tempo multiplier events")
        else:
            # No convincing change point.  If no --bpm anchor was supplied,
            # fit the whole piece with the SAME local fitter the segments
            # use, so --tempo-map also covers the single-tempo case instead
            # of refusing to run.  An explicit --bpm keeps the previous
            # behaviour untouched.
            one = (None if args.bpm is not None
                   else fit_single_segment(rix, args.tick_beat))
            if one is not None:
                single_fit = one
                print("\nTempo-map build (v14 --tempo-map):")
                if detection is not None:
                    print("  detector: " + (
                        f"tempo-map (mad {detection['mad']:.4f})"
                        if detection["verdict"] == "tempo-map" else
                        f"{detection['verdict']} "
                        f"({detection.get('why', 'ok')})"))
                print(f"  no reliable change point ({len(segs)} segment(s)); "
                      "single-tempo local fit:")
                print(f"  seg0: u0={one['u0']:6d} "
                      f"(  0.000s) tick0=     0  "
                      f"bpm={one['bpm']:10.6f}  "
                      f"mult=1.000000  "
                      f"rms={one['rms']:.6f}  n={len(one['rpts'])}")
                print("  -> single-tempo build (no tempo events)")
                map_segments = {"segs": [one], "model": None}
                args.bpm = one["bpm"]
            else:
                print("\n--tempo-map: no reliable tempo-change boundaries "
                      f"found ({len(segs)} segment(s)); falling back to the "
                      "v13 single-tempo path.")

    standard_bnk = find_standard_bnk(args.rix)
    instrument_names, standard_matches, standard_count = match_standard_instruments(
        rix, standard_bnk)
    if standard_bnk is not None:
        if standard_count is None:
            print(f"STANDARD.BNK found but could not be used: {standard_bnk}")
        else:
            print(f"STANDARD.BNK: {standard_bnk}")
            print(f"STANDARD.BNK instruments: {standard_count}")
            if standard_matches:
                print("Matched RIX instruments:")
                for n in sorted(standard_matches):
                    print(f"  RIX{n:02d} -> {standard_matches[n]}")
            else:
                print("No RIX instruments matched STANDARD.BNK; using RIX## names.")
    else:
        print("STANDARD.BNK not found in RIX directory; using RIX## names.")

    # Estimate the BPM from the RIX event grid itself.
    if (args.bpm is not None and map_model is None
            and single_fit is None):
        results, best_fit, plateau, selected = scan_bpm_intrinsic(
            rix, args.bpm, args.tick_beat, args.scan_radius, args.scan_step,
            refine=not args.no_refine)
        print_intrinsic_report(results, best_fit, plateau, selected,
                               refine=not args.no_refine)
        if selected is None:
            print("No note-select events: BPM cannot be fitted; keeping "
                  f"--bpm {args.bpm}.")
        else:
            args.bpm = selected["bpm"]

    if args.bpm is None and map_model is None:
        if args.tempo_map:
            ap.error("--tempo-map found no reliable tempo-change boundaries "
                     "and no --bpm anchor was given; supply --bpm to use "
                     "the single-tempo path")
        ap.error("--bpm is required unless --tempo-map "
                 "is used")

    if args.tempo_multiplier <= 0:
        ap.error("--tempo-multiplier must be positive")

    if map_model is not None:
        # The anchor segment defines the effective tempo for all reporting;
        # per-event ticks come from the piecewise model inside reconstruct.
        args.bpm = map_model["bpms"][0]
        tempo_events = [(bnd, mult) for bnd, mult in
                        zip(map_model["bounds"], map_model["mults"])]
    else:
        tempo_events = None

    rec = reconstruct(rix, args.bpm, args.tick_beat, args.beat_measure,
                      instrument_names, model=map_model)

    out = args.out or args.rix.with_name(args.rix.stem + "_rebuild.ROL")
    bnk = args.bnk or args.rix.with_name(args.rix.stem + "_rebuild.BNK")
    report = args.report or args.rix.with_name(args.rix.stem + "_rebuild.txt")

    rol = build_rol(rix, rec, args.bpm, args.tick_beat, args.beat_measure,
                    args.tempo_multiplier, tempo_events=tempo_events)
    out.write_bytes(rol)

    patches = {
        n: rix_patch(rix["data"], rix["ins_offset"], n)
        for n in rix["instruments"]
    }
    write_bnk(bnk, patches, instrument_names)
    write_report(report, rix, rec, args.bpm, args.tick_beat,
                  args.tempo_multiplier, segments=map_segments)

    print("ROL   :", out)
    print("BNK   :", bnk)
    print("REPORT:", report)
    if tempo_events is not None and map_model is not None:
        sc = map_model["scale"]
        print(f"Actual BPM: {args.bpm}  (grid: beat-level x{sc}; the "
              "piece plays at",
              " .. ".join(f"{b:.2f}" for b in sorted(
                  set(round(b, 2) for b in map_model["beat_bpms"]))),
              "beat BPM)")
    else:
        print("Actual BPM:", args.bpm)
    print("Tempo multiplier:", args.tempo_multiplier)
    print("Basic Tempo:", args.bpm / args.tempo_multiplier)
    print("RIX duration units:", rix["duration_rix"], "ms")
    print("ROL ticks:", rec["end_tick"])
    if map_model is not None:
        # wall clock per segment: ticks advance at that segment's tps
        bnd = list(map_model["bounds"]) + [rec["end_tick"]]
        wall = sum((bnd[i + 1] - bnd[i]) / map_model["tps"][i]
                   for i in range(len(map_model["tps"])))
        print("ROL duration:", wall, "sec (piecewise tempo track)")
    else:
        print("ROL duration:", rec["end_tick"] / rec["ticks_per_second"],
              "sec")

    if tempo_events is not None:
        print("Tempo events:",
              ", ".join(f"tick{t} x{m:g}" for t, m in tempo_events))

    # v14 advisory: the default path stays EXACTLY v13, but when the piece
    # measures as re-tempoed mid-song, tell the user the switch exists.
    if (detection is not None and detection["verdict"] == "tempo-map"
            and tempo_events is None):
        print("")
        print("[!] Tempo-map detected: sliding-window BPM fits spread "
              f"(octave-folded MAD = {detection['mad']:.4f} > 0.02).")
        print("    This piece is NOT one constant tempo; the single-tempo "
              "fit above is a compromise.")
        print("    Re-run with --tempo-map to build it as a multi-tempo "
              "piece (piecewise ROL tempo track).")

    if args.adplay:
        try:
            subprocess.call(["adplay", "-O", "sdl", str(out)])
        except OSError as exc:
            print(f"adplay failed: {exc}")
        except KeyboardInterrupt:
            # Ctrl+C while adplay is playing: exit quietly, no traceback.
            print("")


if __name__ == "__main__":
    main()
