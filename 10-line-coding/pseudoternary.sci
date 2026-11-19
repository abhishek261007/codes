// =============================================================
// Program 10.7 - Pseudoternary Line Coding
// Experiment 11: Line Coding
// Objective: Draw the pseudoternary waveform for the fixed demo bit
//   sequence. Rule: bit 1 -> 0 V; bit 0 -> alternately +A and -A on
//   successive 0s. It is the exact DUAL of AMI (ones and zeros
//   interchanged).
// WHY this matters: pseudoternary was used in low-speed links and
//   ISDN basic access before denser codes took over. Like AMI it has
//   no DC component for any data density, and bipolar violations on
//   the 0s flag single-bit errors. The weakness mirrors AMI: long
//   runs of 1s carry no transitions, starving clock recovery (hence
//   scrambling / HDB3 in real deployments).
// SPECTRUM NOTE: ZERO DC component by construction; energy shifted
//   away from DC; first-null ~ 1/Tb (NRZ-like pulse width).
// IMPLEMENTATION: keep a running polarity flag `pol` that flips after
//   every transmitted 0; ones leave it untouched.
// Convention (used in EVERY file of this experiment):
//   bits = [1 0 1 1 0 0 1 0 1 0 1 1]  (fixed demo sequence)
//   A = 1 V, 0 V, -1 levels; Tb = 1 (unit bit interval);
//   samplesPerBit = 100; x axis labelled "Bit interval (Tb)".
// =============================================================

// ---------------- PARAMETERS ----------------
bits          = [1 0 1 1 0 0 1 0 1 0 1 1];  // fixed demo sequence (same in every file)
A             = 1;        // amplitude, V
samplesPerBit = 100;      // samples per bit
Tb            = 1;        // unit bit interval (normalized), seconds
t             = 0:1/samplesPerBit:length(bits)*Tb - 1/samplesPerBit;
N             = length(t);
// ----------------------------------------------

// WHY a polarity flag: the sign of each ZERO depends on the sign of
// the PREVIOUS zero, so we flip `pol` every time a 0 is sent and
// leave it alone for 1s.
y   = zeros(1, N);
pol = 1;    // first 0 goes out as +A (arbitrary but fixed choice)
for i = 1:length(bits)
    idx = (i-1)*samplesPerBit + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(idx) = 0;       // 1 -> 0 V
    else
        y(idx) = pol*A;   // 0 -> alternating polarity pulse
        pol    = -pol;    // alternate for the NEXT zero
    end
end

// ---------------- RESULTS ----------------
mprintf('Pseudoternary\n');
mprintf('-------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 1 -> 0 V; successive 0s alternate +A / -A (dual of AMI)\n');
mprintf('Zeros in this sequence = %d (polarities alternate regardless of run length)\n', length(bits) - sum(bits));
mprintf('Mean level (DC estimate) = %.4f V (no DC by construction)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: each pulse sits inside one
// bit cell; boundaries make the alternating signs easy to verify.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Pseudoternary: 1 -> 0 V, successive 0s alternate +A / -A');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
