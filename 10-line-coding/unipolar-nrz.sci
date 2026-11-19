// =============================================================
// Program 10.1 - Unipolar NRZ Line Coding
// Experiment 11: Line Coding
// Objective: Draw the Unipolar NRZ waveform for a fixed demo bit
//   sequence and identify its DC component and bandwidth behaviour.
//   Rule: bit 1 -> +A for the WHOLE bit interval; bit 0 -> 0 V.
//   "NRZ" = Non-Return-to-Zero: the signal never returns to 0 in
//   the middle of a bit.
// WHY this matters: Unipolar NRZ is the simplest line code but it
//   has a large DC component (average level = A/2 for equally
//   likely bits), which AC-coupled links (transformers, capacitors)
//   cannot pass, and no guaranteed mid-bit transition, so clock
//   recovery needs extra help (scramblers / PLL with long runs).
// SPECTRUM NOTE: strong DC component + significant low-frequency
//   content; first-null bandwidth ~ 1/Tb (same as the bit rate) for
//   random data. Rich in low frequencies -> poor for AC-coupled
//   channels.
// Convention (used in EVERY file of this experiment):
//   bits = [1 0 1 1 0 0 1 0 1 0 1 1]  (fixed demo sequence)
//   A = 1 V, 0 V, -1 levels; Tb = 1 (unit bit interval);
//   samplesPerBit = 100; x axis labelled "Bit interval (Tb)".
// =============================================================

// ---------------- PARAMETERS ----------------
bits          = [1 0 1 1 0 0 1 0 1 0 1 1];  // fixed demo sequence (same in every file)
A             = 1;        // positive amplitude, V
samplesPerBit = 100;      // samples per bit (keeps transitions sharp)
Tb            = 1;        // unit bit interval (normalized), seconds
t             = 0:1/samplesPerBit:length(bits)*Tb - 1/samplesPerBit;
N             = length(t);
// ----------------------------------------------

// WHY loop over bits: each bit owns exactly samplesPerBit samples,
// so the waveform is built by filling sample ranges - no interpolation,
// no rounded transitions.
y = zeros(1, N);
for i = 1:length(bits)
    idx = (i-1)*samplesPerBit + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(idx) = A;       // 1 -> +A for the full bit
    else
        y(idx) = 0;       // 0 -> 0 V for the full bit
    end
end

// ---------------- RESULTS ----------------
mprintf('Unipolar NRZ\n');
mprintf('-------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 1 -> +A (%.1f V), 0 -> 0 V, level held for the whole bit (no return to zero)\n', A);
mprintf('Mean level (DC estimate) = %.4f V (should approach A/2 = 0.5 for balanced data)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: align each transition to a
// bit cell by eye - makes the "one level per bit" rule obvious.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Unipolar NRZ: 1 -> +A, 0 -> 0');
// WHY data_bounds: fix y limits so 0 V and +A sit nicely centred.
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
