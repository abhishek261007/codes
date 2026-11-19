// =============================================================
// Program 07 - Element-wise Operations
// Experiment 1: Scilab Fundamentals
// Objective: Understand .* ./ .^ (element-wise) vs * / ^
// (matrix) operators, see the error matrix ops produce on
// mismatched vectors, and plot y = t.*sin(t).
// =============================================================

// ---------------- PARAMETERS ----------------
t = 0:0.01:2*%pi;        // time vector, 201 points
v1 = [1 2 3 4 5];        // small demo vectors
v2 = [10 20 30 40 50];
// --------------------------------------------

// --- 1. Element-wise square: v1.^2 ---
// Each element is squared individually: [1 4 9 16 25]
sq_elem = v1 .^ 2;
disp("v1 .^ 2  (element-wise):");
disp(sq_elem);

// --- 2. Element-wise multiply ---
prod_elem = v1 .* v2;    // [10 40 90 160 250]
disp("v1 .* v2 (element-wise product):");
disp(prod_elem);

// --- 3. Element-wise divide ---
ratio_elem = v2 ./ v1;   // [10 10 10 10 10]
disp("v2 ./ v1 (element-wise ratio):");
disp(ratio_elem);

// --- 4. sin(t) .* cos(t): valid because same-size vectors ---
sc = sin(t) .* cos(t);
disp("First 5 values of sin(t).*cos(t):");
disp(sc(1:5));
// Identity check: sin(t)*cos(t) = 0.5*sin(2t)
disp("Max abs difference vs 0.5*sin(2t) (should be ~0):");
disp(max(abs(sc - 0.5*sin(2*t))));

// --- 5. Element-wise vs matrix multiply: THE key contrast ---
// v1 * v2 with plain * is a MATRIX product.
// A 1x5 row vector times a 1x5 row vector is INVALID for matrix
// multiplication (inner dimensions 5 and 1 do not match as
// (1x5)*(1x5)). Scilab raises an inconsistent-dimension error.
// A correct matrix product needs (1x5)*(5x1), i.e. v1 * v2'.
mat_result = v1 * v2';   // scalar: 1*10+2*20+3*30+4*40+5*50 = 550
disp("v1 times transpose of v2 (valid matrix product, dot result):");
disp(mat_result);

// What goes wrong with v1 * v2 (both 1x5)?
//   Scilab: inconsistent multiplication
//   So the "wrong" line is COMMENTED OUT on purpose:
//   bad = v1 * v2;   // <- ERROR: inconsistent dimensions
// The fix: use .* for element-wise, or transpose for matrix math.
disp("NOTE: plain v1 * v2 would fail with an inconsistent-dimension error.");
disp("      Use .* for element-wise, or v1 times v2 transposed for a dot product.");

// --- 6. Matrix ^ vs element-wise .^ ---
// For matrices, A^2 means A*A (matrix square). A.^2 squares entries.
M = [1 2; 3 4];
M_elem = M .^ 2;         // [1 4; 9 16]
M_mat  = M ^ 2;          // M*M = [7 10; 15 22]
disp("M =");
disp(M);
disp("M .^ 2 (entry-wise square):");
disp(M_elem);
disp("M ^ 2  (matrix product M*M):");
disp(M_mat);

// --- 7. Plot y = t.*sin(t): amplitude grows with t ---
y = t .* sin(t);
scf(1);
clf(1);
plot(t, y);
xlabel("t (radians)");
ylabel("y = t .* sin(t)");
title("Growing envelope: y = t.*sin(t)");
xgrid();
disp("Figure 1 plotted: y = t.*sin(t).");
disp("y(pi) should be ~0 (sin(pi) = 0):");
disp(%pi * sin(%pi));

disp("Program 07 complete.");
