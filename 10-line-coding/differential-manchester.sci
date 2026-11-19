// =============================================================
// Program 10.5 - Differential Manchester Line Coding
// Experiment 11: Line Coding
// Objective: Draw the Differential Manchester waveform for the fixed
//   demo bit sequence. Rule (two parts, BOTH mandatory):
//     1) There is ALWAYS a transition in the MIDDLE of every bit.
//     2) bit 0 -> a transition at the START of the bit as well
//        (level at start of bit is OPPOSITE the level of the previous
//        second half); bit 1 -> NO transition at the start
//        (level at start of bit EQUALS the previous second half).
// WHY this matters: the data is encoded in the PRESENCE or ABSENCE
//   of an edge, not in absolute polarity, so the receiver works even
//   if the line is wired backwards (polarity-insensitive). Differential
//   encoding + the guaranteed mid-bit transition makes it robust and
//   self-clocking. Used in token-ring LANs and magnetic recording.
// SPECTRUM NOTE: no DC for balanced data; bandwidth ~ 2/Tb (like
//   Manchester, pulse width Tb/2); strong clock component at 1/Tb.
// IMPLEMENTATION (state machine): let P = level in the SECOND HALF of
//   the previous bit (initial state P = -A before the first bit).
//     bit 1: first half =  P, second half = -P
//     bit 0: first half = -P, second half =  P
//   then update P = level of the second half just drawn.
//   WHY this works: bit 1 keeps the level at the boundary (no extra
//   transition), bit 0 flips it (extra transition at the boundary);
//   both always flip in the middle.
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

// WHY a state variable: differential codes depend on HISTORY, so we
// carry the previous second-half level P through the loop.
y     = zeros(1, N);
P     = -A;   // level of the (imaginary) second half before bit 1; arbitrary choice
for i = 1:length(bits)
    firstHalf  = (i-1)*samplesPerBit + 1 : (i-1)*samplesPerBit + half;
    secondHalf = (i-1)*samplesPerBit + half + 1 : i*samplesPerBit;
    if bits(i) == 1 then
        startLevel = P;      // bit 1: NO transition at bit boundary
    else
        startLevel = -P;     // bit 0: transition at bit boundary
    end
    y(firstHalf)  = startLevel;
    y(secondHalf) = -startLevel;   // mid-bit transition ALWAYS
    P = -startLevel;               // carry second-half level forward
end

// ---------------- RESULTS ----------------
mprintf('Differential Manchester\n');
mprintf('-----------------------\n');
mprintf('Bit sequence: ');
disp(bits);
mprintf('Rule: mid-bit transition ALWAYS; bit 1 -> no transition at start; bit 0 -> transition at start\n');
mprintf('Polarity-insensitive decoding: receiver looks at edges, not absolute levels\n');
mprintf('Mean level (DC estimate) = %.4f V (ideally 0 for balanced data)\n', mean(y));

// ---------------- PLOTS ----------------
scf(1); clf();
plot(t, y, 'b', 'LineWidth', 2);
// WHY dotted verticals at bit boundaries: the start-of-bit edge (for
// bit 0) lands exactly on these lines - watch levels flip there.
for k = 0:length(bits)
    plot([k*Tb k*Tb], [-1.5 1.5], 'k:');
end
xlabel('Bit interval (Tb)');
ylabel('Amplitude (V)');
title('Differential Manchester: mid-bit flip always; bit 0 flips at boundary, bit 1 does not');
a = gca();
a.data_bounds = [0, -1.6; length(bits)*Tb, 1.6];
xgrid();
