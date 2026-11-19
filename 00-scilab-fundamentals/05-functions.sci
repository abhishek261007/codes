// =============================================================
// Program 05 - Functions
// Experiment 1: Scilab Fundamentals
// Objective: Define and call your own functions in a script,
// including a function with TWO outputs, and use them with
// real and complex arguments.
// =============================================================

// ---------------- PARAMETERS ----------------
x_val       = 7;          // real input for squareit
z_val       = 3 + 4*%i;   // complex input for rect2polar_custom
// --------------------------------------------

// --- 1. Simple single-output function ---
// function [out] = name(args) ... endfunction
// Works inside a script that is run with exec("file.sci", -1).
function sq = squareit(x)
    // Returns the square of x. The WHY: squaring is common in
    // power calculations (P = V^2 / R) and energy formulas.
    sq = x * x;
endfunction

// --- 2. Function with two outputs: rectangular -> polar ---
// Given z = a + b*i, return magnitude |z| = sqrt(a^2 + b^2)
// and phase ph = atan(b/a) (using atan with two args is safest).
function [mag, ph] = rect2polar_custom(z)
    // abs() gives the modulus of a complex number.
    mag = abs(z);
    // atan(imag(z), real(z)) handles all quadrants correctly,
    // unlike plain atan(imag/real) which fails near real = 0.
    ph = atan(imag(z), real(z));   // phase in radians
endfunction

// --- 3. Call squareit with a real value ---
y = squareit(x_val);
disp("squareit(7) = (units: squared units of input):");
disp(y);

// --- 4. Call rect2polar_custom with a complex value ---
[magnitude, phase_rad] = rect2polar_custom(z_val);
disp("z = 3 + 4i");
disp("Magnitude |z| (units: same as z, e.g. volts):");
disp(magnitude);                    // should be 5
disp("Phase (radians):");
disp(phase_rad);                    // atan(4,3) ~ 0.9273
phase_deg = phase_rad * 180 / %pi;  // convert to degrees
disp("Phase (degrees):");
disp(phase_deg);                    // ~53.13 degrees

// --- 5. Functions are reusable: use them inside loops ---
disp("Squares of 1..5 via squareit():");
for i = 1:5
    disp(squareit(i));
end

// --- 6. Function on a scalar computed from physics ---
// Kinetic energy: KE = 0.5 * m * v^2. Reuse squareit for v^2.
mass_kg = 2;                        // kg
velocity = 6;                       // m/s
ke = 0.5 * mass_kg * squareit(velocity);  // Joules
disp("Kinetic energy (J):");
disp(ke);

// --- 7. Complex arithmetic sanity check ---
// |z|^2 should equal real^2 + imag^2.
z_check = real(z_val)^2 + imag(z_val)^2;
disp("|z|^2 via parts (should equal magnitude^2 = 25):");
disp(z_check);
disp("magnitude^2 from function:");
disp(magnitude^2);

// --- 8. Another two-output example: rectangle perimeter/area ---
function [area, perim] = rect_geom(w, h)
    // Area and perimeter of a rectangle, in square metres and metres.
    area = w * h;
    perim = 2 * (w + h);
endfunction

[a_rect, p_rect] = rect_geom(3, 4);
disp("Rectangle 3 m x 4 m -> area (m^2):");
disp(a_rect);
disp("Rectangle 3 m x 4 m -> perimeter (m):");
disp(p_rect);

disp("Program 05 complete.");
