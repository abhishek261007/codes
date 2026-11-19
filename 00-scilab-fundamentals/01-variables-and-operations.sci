// =============================================================
// Program 01 - Variables and Operations
// Experiment 1: Scilab Fundamentals
// Objective: Learn how to create variables, understand integer
// vs real numbers, use arithmetic operators, and see how operator
// precedence works. All results are printed with units.
// =============================================================

// ---------------- PARAMETERS ----------------
// Physical constants used in this demo (SI units)
gravity     = 9.8;        // acceleration due to gravity, m/s^2
mass_kg     = 2.5;        // mass of an object, kg
pi_val      = %pi;        // Scilab built-in constant (3.14159...)
e_val       = %e;         // Scilab built-in constant (2.71828...)
// --------------------------------------------

// --- 1. Scalars: integer-like vs real (floating point) ---
// Scilab stores everything as double by default; "integer" below
// just means a value with no fractional part.
count_items = 7;              // whole-number count (no decimals)
masses_ratio = 2.5;           // real number (has a fractional part)

disp("Number of items (whole-number value):");
disp(count_items);
disp("Mass ratio (real value, kg):");
disp(masses_ratio);

// --- 2. Basic arithmetic: + - * / ^ ---
a = 12;
b = 5;
disp("a + b =");
disp(a + b);                  // 17
disp("a - b =");
disp(a - b);                  // 7
disp("a * b =");
disp(a * b);                  // 60
disp("a / b =");
disp(a / b);                  // 2.4 (real division, not integer)
disp("a ^ b = (power)");
disp(a ^ b);                  // 248832

// --- 3. Using %pi: circumference and area of a circle ---
radius = 0.5;                 // metres
circumference = 2 * %pi * radius;   // metres
area = %pi * radius ^ 2;            // square metres (radius squared)
disp("Circumference of circle (m):");
disp(circumference);
disp("Area of circle (m^2):");
disp(area);

// --- 4. %e usage: exponential growth example ---
time_s = 2;                   // seconds
growth = %e ^ time_s;         // e^2
disp("e^2 (dimensionless):");
disp(growth);

// --- 5. Operator precedence ---
// Scilab follows the usual order: ^ first, then * and /, then + and -.
expr1 = 2 + 3 * 4;            // 2 + 12 = 14, NOT 20
expr2 = (2 + 3) * 4;          // parentheses first: 20
expr3 = 2 ^ 3 ^ 2;            // ^ is right-associative: 2^(3^2) = 512
expr4 = 10 - 6 / 2;           // 10 - 3 = 7
disp("2 + 3 * 4 =");
disp(expr1);
disp("(2 + 3) * 4 =");
disp(expr2);
disp("2 ^ 3 ^ 2 =");
disp(expr3);
disp("10 - 6 / 2 =");
disp(expr4);

// --- 6. Physics example: free fall distance ---
// distance = 0.5 * g * t^2, with g in m/s^2 and t in seconds
fall_time = 3;                // seconds
distance = 0.5 * gravity * fall_time ^ 2;   // metres
disp("Distance fallen in 3 s (m):");
disp(distance);

// --- 7. Weight of the object (Force = m * g) ---
weight_N = mass_kg * gravity; // Newtons
disp("Weight of 2.5 kg object (N):");
disp(weight_N);

// --- 8. Why precedence matters: energy stored = 0.5*m*v^2 ---
velocity = 4;                 // m/s
kinetic = 0.5 * mass_kg * velocity ^ 2;   // Joules
disp("Kinetic energy (J):");
disp(kinetic);

disp("Program 01 complete.");
