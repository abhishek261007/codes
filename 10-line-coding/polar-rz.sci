// =============================================================
// Program 10.3 - Polar RZ Line Coding
// Experiment 11: Line Coding
// Objective: Draw the Polar Return-to-Zero waveform for the fixed
//   demo bit sequence. Rule: bit 1 -> +A for the FIRST HALF of the
//   bit, then back to 0 for the second half; bit 0 -> -A for the
//   first half, then back to 0.
// WHY this matters: the deliberate return to zero in the middle of
//   EVERY bit guarantees a transition per bit cell, so the receiver
//   can recover the clock from the data itself. The price is double
//   the bandwidth of NRZ (shorter pulses -> wider spectrum).
// SPECTRUM NOTE: spectral nulls at multiples of 1/Tb for random
//   data - the PSD has no DC for balanced data and discrete nulls at
//   the bit rate and its harmonics, which helps clock recovery with
//   a simple narrowband filter at 1/Tb. Bandwidth ~ 2/Tb (double NRZ).
// Convention (used in EVERY file of this experiment):
//   bits = [1 0 1 1 0 0 1 0 1 0 1 1]  (fixed demo sequence)
//   A = 1 V, 0 V, -1 levels; Tb = 1 (unit bit interval);
//   samplesPerBit = 100; x axis labelled "Bit interval (Tb)".
// =============================================================

// ---------------- PARAMETERS ----------------
bits          = [1 0 1 1 0 0 1 0 1 0 1 1];  // fixed demo sequence (same in every file)
A             = 1;        // amplitude, V
samplesPerBit = 100;      // samples per bit (must be EVEN for a clean half-bit split)
Tb            = 1;        // unit bit interval (normalized), seconds
t             = 0:1/samplesPerBit:length(bits)*Tb - 1/samplesPerBit;
N             = length(t);
half          = samplesPerBit/2;   // samples in the first (active) half of a bit
// ----------------------------------------------

// WHY half-bit fill: first half carries +/-A, second half is held at
// zero - the mandatory return to zero is what gives RZ its clocking
// advantage and its wider spectrum.
y = zeros(1, N);
for i = 1:length(bits)
    firstHalf  = (i-1)*samplesPerBit + 1 : (i-1)*samplesPerBit + half;
    secondHalf = (i-1)*samplesPerBit + half + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(firstHalf)  = A;
        y(secondHalf) = 0;
    else
        y(firstHalf)  = -A;
        y(secondHalf) = 0;
    end
end

// ---------------- RESULTS ----------------
mprintf('Polar RZ (Return-to-Zero)\n');
mprintf('-------------------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 1 -> +A for first Tb/2 then 0; 0 -> -A for first Tb/2 then 0\n');
mprintf('Every bit has a mid-bit return to zero -> guaranteed transition density for clock recovery\n');
mprintf('Mean level (DC estimate) = %.4f V (ideally 0 for balanced data)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: shows the return-to-zero
// happens halfway through each cell, before the boundary.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Polar RZ: +/-A for first half of bit, 0 for second half');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
