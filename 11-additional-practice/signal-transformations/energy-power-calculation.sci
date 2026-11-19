// ============================================================
// Practice Program: energy-power-calculation.sci
// Difficulty: Intermediate
// Topic: Signal energy and power
// -----------------------------------------------------------
// PROBLEM STATEMENT: Compute the energy of a rectangular pulse (joules) and the average power of a sine (watts, normalized).
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A_pulse = 2;         // rectangular pulse amplitude, volts
pw      = 0.05;      // pulse width, seconds
A_sin   = 3;         // sine amplitude, volts
f_sin   = 50;        // sine frequency, Hz
fs      = 100000;    // sampling frequency, Hz (fine grid for accuracy)
dt      = 1 / fs;    // sample spacing, seconds
T_sin   = 10 / f_sin; // 10 periods of the sine for a stable average
// -------------------------------------------

// --- 1. Rectangular pulse: energy signal ---
t_p = 0:dt:(pw + 0.02);                    // window a bit wider than the pulse
pulse = A_pulse * ones(t_p);                // high everywhere...
pulse = pulse .* (t_p >= 0 & t_p <= pw);    // ...then gate to [0, pw]
E_rect = sum(pulse.^2) * dt;                // E = integral of |x(t)|^2 dt
E_theory = A_pulse^2 * pw;                  // theory: A^2 * pulse width
mprintf("Energy of rectangular pulse (computed) = %f J\n", E_rect);
mprintf("Energy of rectangular pulse (A^2 * pw) = %f J\n", E_theory);

// --- 2. Sine wave: power signal ---
t_s = 0:dt:T_sin;
x_sin = A_sin * sin(2 * %pi * f_sin * t_s);
P_sin = mean(x_sin.^2);                     // P = average of x^2 over periods
P_theory = A_sin^2 / 2;                     // theory: A^2 / 2 for a sine
mprintf("Average power of sine (computed)   = %f W (normalised, 1 ohm)\n", P_sin);
mprintf("Average power of sine (A^2 / 2)    = %f W (normalised, 1 ohm)\n", P_theory);

// --- 3. Which one is which? ---
disp("Energy signals (pulse): finite energy, zero average power.");
disp("Power signals (sine): infinite energy, finite average power.");

// --- 4. Plots ---
clf;
subplot(2, 1, 1);
plot(t_p, pulse, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Rectangular pulse: energy signal"); xgrid;
subplot(2, 1, 2);
plot(t_s(1:2000), x_sin(1:2000), "r-");    // first 0.02 s for readability
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("50 Hz sine: power signal (showing first 20 ms)"); xgrid;

disp("Energy and power calculation complete.");
