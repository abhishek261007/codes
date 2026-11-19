// =============================================================
// Program 10.2 - Polar NRZ (NRZ-L) Line Coding
// Experiment 11: Line Coding
// Objective: Draw the Polar NRZ waveform for the fixed demo bit
//   sequence and show that antipodal levels cancel the DC term.
//   Rule: bit 1 -> +A for the WHOLE bit; bit 0 -> -A for the WHOLE bit.
// WHY this matters: sending +A/-A instead of +A/0 doubles the
//   signal swing around zero. For equally likely 1s and 0s the mean
//   level is ideally 0 (no DC), so polar NRZ survives AC coupling
//   far better than unipolar NRZ. Still NO mid-bit transitions, so
//   long runs of identical bits starve the receiver clock recovery.
// SPECTRUM NOTE: no DC component for balanced data; first-null
//   bandwidth ~ 1/Tb; energy concentrated near low frequencies;
//   double the Euclidean distance between the two levels vs unipolar
//   (better noise immunity for the same peak power).
// Convention (used in EVERY file of this experiment):
//   bits = [1 0 1 1 0 0 1 0 1 0 1 1]  (fixed demo sequence)
//   A = 1 V, 0 V, -1 levels; Tb = 1 (unit bit interval);
//   samplesPerBit = 100; x axis labelled "Bit interval (Tb)".
// =============================================================

// ---------------- PARAMETERS ----------------
bits          = [1 0 1 1 0 0 1 0 1 0 1 1];  // fixed demo sequence (same in every file)
A             = 1;        // amplitude, V (positive and negative swing)
samplesPerBit = 100;      // samples per bit
Tb            = 1;        // unit bit interval (normalized), seconds
t             = 0:1/samplesPerBit:length(bits)*Tb - 1/samplesPerBit;
N             = length(t);
numOnes       = sum(bits);
numZeros      = length(bits) - numOnes;
// ----------------------------------------------

// WHY loop over bits: each bit owns exactly samplesPerBit samples;
// filling sample ranges keeps transitions perfectly vertical.
y = zeros(1, N);
for i = 1:length(bits)
    idx = (i-1)*samplesPerBit + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(idx) = A;        // 1 -> +A
    else
        y(idx) = -A;       // 0 -> -A
    end
end

// ---------------- RESULTS ----------------
mprintf('Polar NRZ (NRZ-L)\n');
mprintf('-----------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 1 -> +A (%.1f V), 0 -> -A (%.1f V), held for the whole bit\n', A, A);
mprintf('Ones = %d, Zeros = %d\n', numOnes, numZeros);
// WHY report mean: with 6 ones and 6 zeros the DC estimate is exactly
// zero; unbalanced sequences leave a residual DC.
mprintf('Mean level (DC estimate) = %.4f V (ideally 0 for balanced data)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: align levels to bit cells by eye.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Polar NRZ: 1 -> +A, 0 -> -A');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
