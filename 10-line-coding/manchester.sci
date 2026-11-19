// =============================================================
// Program 10.4 - Manchester (Bi-phase) Line Coding, IEEE 802.3
// Experiment 11: Line Coding
// Objective: Draw the Manchester waveform for the fixed demo bit
//   sequence. IEEE 802.3 rule: bit 1 = LOW -> HIGH transition in the
//   MIDDLE of the bit (first half -A, second half +A);
//   bit 0 = HIGH -> LOW transition in the middle
//   (first half +A, second half -A).
// WHY this matters: there is ALWAYS a mid-bit transition, so the
//   data stream is self-clocking - Ethernet (10 Mbit/s coax/TP) and
//   IRIG-B timecode use Manchester for exactly this reason.
//   Antipodal half-bits give zero DC for balanced data.
// SPECTRUM NOTE: no DC for balanced data; NO spectral energy at DC,
//   first-null at 2/Tb; bandwidth roughly DOUBLE NRZ (pulse width Tb/2).
//   Clock energy sits at 1/Tb -> easy to extract with a PLL.
// COMMON PITFALL: many textbooks use the opposite convention
//   (1 = high->low). IEEE 802.3 (and this file) uses 1 = low->high.
//   Always state the convention when quoting Manchester results.
// Convention (used in EVERY file of this experiment):
//   bits = [1 0 1 1 0 0 1 0 1 0 1 1]  (fixed demo sequence)
//   A = 1 V, 0 V, -1 levels; Tb = 1 (unit bit interval);
//   samplesPerBit = 100; x axis labelled "Bit interval (Tb)".
// =============================================================

// ---------------- PARAMETERS ----------------
bits          = [1 0 1 1 0 0 1 0 1 0 1 1];  // fixed demo sequence (same in every file)
A             = 1;        // amplitude, V
samplesPerBit = 100;      // samples per bit (even -> clean mid-bit split)
Tb            = 1;        // unit bit interval (normalized), seconds
t             = 0:1/samplesPerBit:length(bits)*Tb - 1/samplesPerBit;
N             = length(t);
half          = samplesPerBit/2;
// ----------------------------------------------

// WHY half-bit fill: Manchester encodes the bit as a TRANSITION
// DIRECTION, so we draw two complementary half-bits.
y = zeros(1, N);
for i = 1:length(bits)
    firstHalf  = (i-1)*samplesPerBit + 1 : (i-1)*samplesPerBit + half;
    secondHalf = (i-1)*samplesPerBit + half + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        y(firstHalf)  = -A;   // 1 = LOW -> HIGH (IEEE 802.3)
        y(secondHalf) =  A;
    else
        y(firstHalf)  =  A;   // 0 = HIGH -> LOW (IEEE 802.3)
        y(secondHalf) = -A;
    end
end

// ---------------- RESULTS ----------------
mprintf('Manchester (IEEE 802.3)\n');
mprintf('-----------------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: 1 -> -A then +A (LOW->HIGH mid-bit); 0 -> +A then -A (HIGH->LOW mid-bit)\n');
mprintf('Every bit cell contains one mid-bit transition -> self-clocking\n');
mprintf('Mean level (DC estimate) = %.4f V (ideally 0 for balanced data)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: mid-bit transitions flip
// INSIDE a cell; boundary lines separate the cells for reading.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Manchester (IEEE 802.3): 1 = LOW->HIGH, 0 = HIGH->LOW');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
