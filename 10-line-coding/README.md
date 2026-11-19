# 10 — Line Coding (Experiment 11)

## Objective

Study how binary data is mapped onto electrical waveforms for digital transmission.
For each of the seven classic line codes, generate the waveform for a fixed demo
bit sequence, observe its levels, transitions, DC content and clock-recovery
properties, and compare the codes systematically.

## Theory

**Why line coding?** The raw bit stream (1s and 0s) cannot be pushed onto a wire
directly. A *line code* converts bits into pulses with desirable properties:

- **DC / spectral shaping** — many links (transformers, capacitively coupled
  circuits, some fiber transceivers) cannot pass DC, so the transmitted
  waveform must have zero (or very low) average energy at DC.
- **Clock recovery** — the receiver must sample the line at the right instants.
  Codes with frequent transitions let a PLL (phase-locked loop) synchronize to
  the data itself. Long runs of identical bits carry no timing information.
- **Error detection** — some codes (AMI, pseudoternary) embed redundancy: any
  violation of the alternation rule signals a bit error on the line.

### The demo bit sequence (used in every file)

```
bits = [1 0 1 1 0 0 1 0 1 0 1 1]     (12 bits: seven 1s, five 0s)
A = 1 V (positive), 0 V (zero), -1 V (negative)
Tb = 1 (unit bit interval, normalized); axis label "Bit interval (Tb)"
samplesPerBit = 100   -> sharp, vertical transitions
t = 0 : 1/samplesPerBit : length(bits) - 1/samplesPerBit
```

Using the SAME sequence in every file makes the waveforms directly comparable
by eye. A fixed sequence (not random) keeps the experiment reproducible.

### Format-by-format rules

**1. Unipolar NRZ** — `1 → +A`, `0 → 0 V`, level held for the whole bit (no
return to zero).

```
bit:   1       0       1       1
      +---+   0   0   +---+ +---+
```

Simple, but the average level is A/2 for balanced data → **large DC component**,
no guaranteed transitions → poor for AC-coupled links and self-clocking.

**2. Polar NRZ (NRZ-L)** — `1 → +A`, `0 → −A`, held for the whole bit.
Antipodal levels double the Euclidean distance between symbols (better noise
margin). For balanced data the DC component ideally cancels (mean = 0), but
long runs of identical bits still starve clock recovery. No mid-bit transitions.

**3. Polar RZ (Return-to-Zero)** — `1 → +A` for the **first half** of the bit
then back to 0; `0 → −A` for the first half then back to 0. The mandatory
return to zero guarantees a transition every bit → clock recovery is easy, and
the spectrum has **nulls at multiples of 1/Tb**. Cost: **double the bandwidth**
of NRZ (pulse width Tb/2).

**4. Manchester (IEEE 802.3)** — `1` = LOW→HIGH (first half −A, second half
+A); `0` = HIGH→LOW (first half +A, second half −A). There is **ALWAYS a
mid-bit transition** → perfectly self-clocking. Zero DC for balanced data.
Bandwidth ≈ 2/Tb (double NRZ). Used in 10 Mbit/s Ethernet and IRIG-B.
Note: some textbooks use the opposite convention (1 = HIGH→LOW); IEEE 802.3
uses 1 = LOW→HIGH, and that is what `manchester.sci` draws.

```
bit 1:  ---__    (low then high; rising edge mid-bit)
bit 0:  __---    (high then low; falling edge mid-bit)
```

**5. Differential Manchester** — (a) there is **ALWAYS** a mid-bit transition;
(b) `0` → **extra transition at the START** of the bit (start level is the
opposite of the previous second-half level); `1` → **no transition at the
start** (start level equals the previous second-half level). Data is in the
presence/absence of an edge, not absolute polarity → **polarity-insensitive**
decoding (works with reversed wiring). Used in Token-Ring LANs and magnetic
recording. Same bandwidth as Manchester (≈ 2/Tb), zero DC for balanced data.

**6. AMI (Alternate Mark Inversion)** — `0 → 0 V`; `1` ("mark") → alternately
`+A`, `−A`, `+A`, … The alternation kills the DC component for **any** density
of ones. Any "bipolar violation" (two consecutive marks of the same polarity)
flags a single-bit error. Used in T1/E1 carrier systems. Weakness: long runs
of zeros → no transitions (fixed in practice with scrambling or HDB3).

**7. Pseudoternary** — the exact dual of AMI: `1 → 0 V`; `0` → alternately
`+A`, `−A`, … Zero DC by the same alternation argument; bipolar violations on
the zeros flag errors. Used in low-speed links / ISDN basic access. Weakness:
long runs of ones carry no timing information.

### Code comparison table

| Code | Levels | DC component | Clock recovery | Error detection | Bandwidth (≈) |
|---|---|---|---|---|---|
| Unipolar NRZ | +A, 0 | Large (A/2) | Poor | No | 1/Tb |
| Polar NRZ | +A, −A | Zero (balanced) | Poor | No | 1/Tb |
| Polar RZ | +A, −A, 0 | Zero (balanced); nulls at n/Tb | Good (mid-bit RTZ) | No | 2/Tb |
| Manchester (IEEE) | +A, −A | Zero | Excellent (mid-bit edge) | No | 2/Tb |
| Differential Manchester | +A, −A | Zero | Excellent (mid-bit edge) | No | 2/Tb |
| AMI | +A, 0, −A | Zero (by alternation) | Fair–poor (zero runs) | Yes (bipolar violations) | 1/Tb |
| Pseudoternary | +A, 0, −A | Zero (by alternation) | Fair–poor (one runs) | Yes (bipolar violations) | 1/Tb |

## Parameter meanings

| Symbol | Meaning | Value used |
|---|---|---|
| `bits` | Fixed demo bit sequence (same in every file) | `[1 0 1 1 0 0 1 0 1 0 1 1]` |
| `A` | Positive/negative amplitude | `1` V |
| `samplesPerBit` | Samples per bit cell; keeps transitions sharp | `100` |
| `Tb` | Unit bit interval (normalized) | `1` (axis label "Bit interval (Tb)") |
| `t` | Sample time axis `0 : 1/samplesPerBit : length(bits) - 1/samplesPerBit` | 0 … 11.99 |
| `y` | Line-coded waveform | built by filling each bit's sample range |
| `half` | Sample index of the half-bit split (RZ/Manchester codes) | `samplesPerBit/2` |
| `pol` | Running polarity flag for AMI / pseudoternary | starts at `+1`, flips per pulse |
| `P` | Previous second-half level state (differential Manchester) | starts at `-A` |

Dotted vertical lines are drawn at every bit boundary (`k*Tb`, k = 0…12) to
align levels with bit cells; y-limits are fixed to `[-1.6, 1.6]` via
`gca().data_bounds`; `xgrid()` is enabled on every plot.

## How to run

Linux, Scilab 2024.1, from a fresh session:

```sh
cd /home/abhishek/scilab-communications-lab/10-line-coding
scilab -nw -nb -e "exec('unipolar-nrz.sci', -1)"
scilab -nw -nb -e "exec('polar-nrz.sci', -1)"
scilab -nw -nb -e "exec('polar-rz.sci', -1)"
scilab -nw -nb -e "exec('manchester.sci', -1)"
scilab -nw -nb -e "exec('differential-manchester.sci', -1)"
scilab -nw -nb -e "exec('ami.sci', -1)"
scilab -nw -nb -e "exec('pseudoternary.sci', -1)"
```

(or open each `.sci` in the Scilab editor and press Execute.)

## Expected plots and interpretation

All plots show amplitude vs "Bit interval (Tb)" with dotted vertical lines at
bit boundaries, over the 12-bit demo sequence.

- **unipolar-nrz.sci** — pulses sit at +A for every 1, zero otherwise. The
  mean level printed by the script is ≈ 7/12 ≈ 0.58 V (7 ones in the demo
  sequence) — visible offset above 0 is the DC component in one plot.
  Expected console line: `Mean level (DC estimate) = 0.5833 V`.
- **polar-nrz.sci** — symmetric ±A pulses; with 7 ones / 5 zeros the printed
  mean is ≈ +0.167 V (residual DC from the unbalanced demo sequence; exactly
  0 only for balanced data). Watch that transitions happen only at boundaries.
- **polar-rz.sci** — pulses occupy only the FIRST HALF of each active bit cell
  and fall to 0 in the second half. Every bit shows a mid-bit return to 0.
  Console prints the "mid-bit return to zero ⇒ clock recovery" note.
- **manchester.sci** — every cell is either rising (1: −A → +A) or falling
  (0: +A → −A), always with a mid-bit edge. Cells: 1,0,1,1,0,0,1,0,1,0,1,1.
- **differential-manchester.sci** — same mid-bit flips as Manchester, but bit 0
  cells additionally flip at the boundary. Decode by watching edges, not
  polarity. Console prints the rule reminder.
- **ami.sci** — 0s sit at 0 V; the seven 1s alternate +A, −A, +A, −A, +A, −A,
  +A (first mark +A). Console prints `Marks in this sequence = 7`.
- **pseudoternary.sci** — 1s sit at 0 V; the five 0s alternate +A, −A, +A,
  −A, +A. Console prints `Zeros in this sequence = 5`.

## Observations

1. Unipolar NRZ is the only code with a clearly visible non-zero mean on the
   plot; all others sit centred on 0 V.
2. Manchester and differential Manchester contain exactly one transition per
   half-bit cell — the densest timing information of the set, at the cost of
   doubling the bandwidth.
3. AMI and pseudoternary transmit three levels but carry one bit per cell —
   the third level is redundancy used for error detection (bipolar violations).
4. Long zero runs in AMI (e.g. bits 5–6 = `00`) contain no transitions; the
   receiver PLL would drift — the reason real systems add scrambling/HDB3.
5. DC estimates printed by the scripts: unipolar ≈ 0.58 V, polar NRZ ≈ 0.17 V,
   Manchester/differential ≈ 0.00 V, AMI ≈ 0.08 V, pseudoternary ≈ 0.17 V;
   only unipolar is unusable on DC-blocked links.
6. RZ and Manchester need twice the bandwidth of NRZ-class codes for the same
   bit rate — the fundamental clocking-vs-bandwidth trade-off.

## Common mistakes

1. **Manchester convention flipped** — drawing 1 as HIGH→LOW. IEEE 802.3 is
   1 = LOW→HIGH, 0 = HIGH→LOW; always state the convention.
2. **Differential rule inverted** — giving 1 the boundary transition and 0 the
   no-transition case. Correct: 0 flips at the start, 1 keeps the level; BOTH
   flip mid-bit.
3. **AMI polarity not alternating** — e.g. resetting the polarity flag every
   bit instead of every mark. The flag must flip ONLY on 1s (AMI) / 0s
   (pseudoternary), never on the zero-level bits.
4. **Too few samples per bit** (e.g. 4) — transitions look slanted/staircased
   instead of vertical; use 100 samples/bit.
5. **Forgetting the mid-bit transition** in RZ/Manchester — the defining
   property of the code; check that every cell contains exactly one edge.
6. **Using random bits** — results are not reproducible; the fixed demo
   sequence exists so waveforms and console numbers match exactly every run.
7. **Plotting t up to length(bits)** instead of `length(bits) - 1/samplesPerBit`
   — axis overshoots by one sample.
8. **Leaving `y` uninitialized** — Scilab does not auto-vivify zeros for
   indexed assignment in all contexts; always `y = zeros(1, N)` first.
9. **Assuming zero DC means zero baseline wander always** — real channels with
   unbalanced data (our demo has 7 ones, 5 zeros) reintroduce a small mean;
   the alternating codes only cancel DC in the balanced limit.

## Viva questions with answers

**Q1. Why can't we transmit raw baseband bits over a telephone line as-is?**
A: The channel frequency response, impedance matching and coupling elements
(transformers/capacitors) were designed for analog voice, not for a two-level
DC signal; line coding shapes the spectrum (removes/controls DC, limits
bandwidth) so the waveform passes the channel with low distortion and lets
the receiver recover timing and detect errors.

**Q2. What does "NRZ" mean and what is its main drawback?**
A: Non-Return-to-Zero — the signal holds its level for the whole bit and does
not return to 0 mid-cell. Drawback: long runs of identical bits give no
transitions, so the receiver cannot extract the clock and baseline wander
(DC drift) accumulates.

**Q3. Why does unipolar NRZ have a DC component and polar NRZ (ideally) not?**
A: Unipolar's levels are +A and 0 → average A/2 for equally likely bits.
Polar's levels are +A and −A → average 0 when ones and zeros are equally
likely (antipodal signalling). Unbalanced data still leaves a residual DC in
polar NRZ.

**Q4. How does RZ help clock recovery?**
A: Every pulse returns to zero in the middle of the bit, so there is a
guaranteed transition once per bit cell; a narrowband PLL at the bit rate can
lock onto this periodic component. Bonus: AMI/polar RZ spectra have nulls at
multiples of 1/Tb.

**Q5. State the IEEE 802.3 Manchester rule.**
A: Bit 1 = LOW→HIGH transition at mid-bit (−A first half, +A second half);
bit 0 = HIGH→LOW (+A first half, −A second half). There is always exactly one
mid-bit edge; the direction of the edge carries the data.

**Q6. Why do some books define Manchester the opposite way? Which is right?**
A: Both conventions exist historically (G.E. Thomas vs IEEE 802.3). IEEE
802.3 (Ethernet) defines 1 = LOW→HIGH. They are bit-complements; for
transmission it does not matter as long as TX and RX agree, but exam answers
must quote the standard being used.

**Q7. What is differential Manchester and why use it?**
A: Always a mid-bit transition; bit 0 adds a transition at the bit boundary,
bit 1 does not. Decoding depends on the presence/absence of an edge relative
to the previous cell, not on absolute polarity, so a receiver with reversed
line wiring still decodes correctly (polarity insensitivity). Also immune to
systematic inversion, useful on magnetic media and token-ring links.

**Q8. Explain AMI and its error-detection property.**
A: Alternate Mark Inversion: zeros → 0 V, ones → alternating +A/−A. The
alternation cancels DC for any ones-density. In a correct transmission every
mark must alternate in polarity; two consecutive same-polarity marks ("bipolar
violation") are physically impossible from an encoder, so they must be a
single-bit error (or intersymbol interference artifact).

**Q9. What is the weakness of AMI and how is it fixed?**
A: Long runs of zeros produce no transitions → clock recovery fails and the
line looks dead. Fix: scrambling with a pseudo-random sequence, or codes like
HDB3 (High-Density Bipolar order 3) that substitute coded pulses for long
zero runs, guaranteeing transition density.

**Q10. How does pseudoternary differ from AMI?**
A: It is the exact dual: 1 → 0 V, and zeros are the alternating ±A marks.
Same zero-DC and bipolar-violation properties; suited to data with few zeros
(such as some low-speed signalling and ISDN basic access).

**Q11. Which codes give you free error detection and why?**
A: AMI and pseudoternary. They use three line levels to carry one bit per
cell; the third level is redundant state. Any violation of the alternation
rule guarantees an error. Manchester/NRZ/RZ use two levels — no redundancy,
no error detection.

**Q12. Compare the bandwidths: NRZ vs RZ vs Manchester.**
A: Pulse width: NRZ = Tb, RZ/Manchester = Tb/2. First spectral null scales as
1/(pulse width): NRZ ≈ 1/Tb, RZ and Manchester ≈ 2/Tb. So Manchester costs
double the bandwidth of NRZ in exchange for self-clocking; RZ sits at 2/Tb
but keeps NRZ-like (not self-clocking-every-bit, only RZ) transition density.
In short: the more timing information you embed, the wider the spectrum —
bandwidth vs clocking is the central trade-off of line codes.
