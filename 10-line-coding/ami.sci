// =============================================================
// Program 10.6 - AMI (Alternate Mark Inversion) Line Coding
// Experiment 11: Line Coding
// Objective: Draw the AMI waveform for the fixed demo bit sequence.
//   Rule: bit 0 -> 0 V; bit 1 ("mark") -> alternately +A and -A on
//   successive 1s (bipolar with no return to zero mid-bit).
// WHY this matters: the bipolar alternation cancels the DC component
//   for ANY density of ones, so AMI works on AC-coupled links even
//   with unbalanced data. Because every violation of the expected
//   alternation is a detectable error, AMI gives single-error
//   detection for free on the line (bipolar violations). Long runs
//   of zeros, however, carry no transitions at all - receivers use
//   scrambling or HDB3 to restore clocking.
// SPECTRUM NOTE: ZERO DC component by construction; energy shifted
//   to higher frequencies; first-null ~ 1/Tb (NRZ-like pulse width);
//   a dip (not a spike) of energy at frequencies near DC.
// IMPLEMENTATION: keep a running polarity flag `pol` that flips after
//   every transmitted 1; zeros leave it untouched.
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

// WHY a polarity flag: AMI is history-dependent - the sign of each 1
// depends on the sign of the PREVIOUS 1, so we flip `pol` every time
// a 1 is sent and leave it alone for 0s.
y   = zeros(1, N);
pol = 1;    // first 1 goes out as +A (arbitrary but fixed choice)
for i = 1:length(bits)
    idx = (i-1)*samplesPerBit + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(idx) = pol*A;   // mark -> current polarity
        pol    = -pol;    // alternate for the NEXT mark
    else
        y(idx) = 0;       // space -> 0 V
    end
end

// ---------------- RESULTS ----------------
mprintf('AMI (Alternate Mark Inversion)\n');
mprintf('------------------------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 0 -> 0 V; successive 1s alternate +A / -A\n');
mprintf('Marks in this sequence = %d (polarities alternate regardless of run length)\n', sum(bits));
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
title('AMI: 0 -> 0 V, successive 1s alternate +A / -A');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
