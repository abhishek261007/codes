// ============================================================
// Practice Program: even-odd-decomposition.sci
// Difficulty: Intermediate
// Topic: Signal transformations (even / odd decomposition)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Decompose an arbitrary x(t) into its even part xe and odd part xo; verify x = xe + xo.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
fs = 100;           // 100 samples per second
dt = 1 / fs;        // sample spacing, seconds
t  = -2:dt:2;       // symmetric grid (required for even/odd parts)
// -------------------------------------------

// --- 1. Arbitrary (neither even nor odd) signal, defined for all t ---
// x(t) = t^2 for t < 0  and  x(t) = 2 - t for t >= 0   (triangle-like)
x = (t.^2) .* (t < 0) + (2 - t) .* (t >= 0);

// --- 2. Build x(-t) by mirroring the symmetric grid ---
// WHY: on a uniform, symmetric grid, x(-t(i)) is just x read backwards.
x_rev = x(length(x):-1:1);

// --- 3. Even and odd parts ---
xe = (x + x_rev) / 2;     // satisfies xe(t) = xe(-t)
xo = (x - x_rev) / 2;     // satisfies xo(t) = -xo(-t)

// --- 4. Verify reconstruction x = xe + xo ---
recon_err = max(abs(x - xe - xo));
mprintf("max |x - xe - xo| = %e (should be ~0)\n", recon_err);
mprintf("max |xe - mirror(xe)| = %e (even part check, ~0)\n", ...
        max(abs(xe - xe(length(xe):-1:1))));
mprintf("max |xo + mirror(xo)| = %e (odd part check, ~0)\n", ...
        max(abs(xo + xo(length(xo):-1:1))));

// --- 5. Plots: original, even, odd parts ---
clf;
subplot(3, 1, 1);
plot(t, x, "b-");
xlabel("Time (s)"); ylabel("x(t)");
title("Original arbitrary signal x(t)"); xgrid;
subplot(3, 1, 2);
plot(t, xe, "g-");
xlabel("Time (s)"); ylabel("xe(t)");
title("Even part xe(t) = [x(t) + x(-t)] / 2"); xgrid;
subplot(3, 1, 3);
plot(t, xo, "r-");
xlabel("Time (s)"); ylabel("xo(t)");
title("Odd part xo(t) = [x(t) - x(-t)] / 2"); xgrid;

disp("Even-odd decomposition complete.");
