// ============================================================
// Practice Program: time-scaling.sci
// Difficulty: Intermediate
// Topic: Signal transformations (time scaling)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Compare x(2t) and x(t/2) with the base signal; disp the effect on time support.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
pw = 0.4;          // base pulse width, seconds
fs = 2000;         // sampling frequency, Hz
dt = 1 / fs;       // sample spacing, seconds
t  = -1:dt:1;      // wide window so the expanded signal still fits
// -------------------------------------------

// --- 1. Base signal: triangular pulse on [0, pw] ---
// WHY: a triangle is simple to evaluate analytically at any scaled time.
function [y] = tri_pulse(u, width)
    y = zeros(u);
    for i = 1:length(u)
        if u(i) >= 0 & u(i) <= width / 2 then
            y(i) = 2 * u(i) / width;                 // rising edge
        elseif u(i) > width / 2 & u(i) <= width then
            y(i) = 2 * (width - u(i)) / width;       // falling edge
        end
    end
endfunction

// --- 2. Base, compressed x(2t) and expanded x(t/2) ---
x      = tri_pulse(t, pw);          // x(t)
x_comp = tri_pulse(2 * t, pw);      // x(2t): squeezed in time, finishes earlier
x_exp  = tri_pulse(t / 2, pw);      // x(t/2): stretched in time, ends later

// --- 3. Measure support (non-zero span) of each ---
function [w] = support_width(u, y, thr)
    idx = find(abs(y) > thr);
    if length(idx) == 0 then
        w = 0;
    else
        w = u(idx($)) - u(idx(1));
    end
endfunction
w0 = support_width(t, x, 1e-6);
w2 = support_width(t, x_comp, 1e-6);
w1 = support_width(t, x_exp, 1e-6);
mprintf("Support of x(t)    ~= %f s (base width %f s)\n", w0, pw);
mprintf("Support of x(2t)   ~= %f s (halved: compressed)\n", w2);
mprintf("Support of x(t/2)  ~= %f s (doubled: expanded)\n", w1);
disp("x(a*t) with a>1 compresses the signal; 0<a<1 expands it; amplitude unchanged.");

// --- 4. Plots: all three on one figure ---
clf;
subplot(3, 1, 1);
plot(t, x, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("x(t): base triangular pulse on [0, 0.4]"); xgrid;
subplot(3, 1, 2);
plot(t, x_comp, "r-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("x(2t): time-compressed (support halved)"); xgrid;
subplot(3, 1, 3);
plot(t, x_exp, "g-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("x(t/2): time-expanded (support doubled)"); xgrid;

disp("Time scaling complete.");
