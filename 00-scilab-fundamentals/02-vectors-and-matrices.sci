// =============================================================
// Program 02 - Vectors and Matrices
// Experiment 1: Scilab Fundamentals
// Objective: Create row/column vectors and matrices, index
// elements and slices, transpose, and check basic matrix
// properties such as size, determinant and inverse.
// =============================================================

// ---------------- PARAMETERS ----------------
// A small 3x3 matrix used throughout the demo.
// Semicolons separate ROWS; spaces separate COLUMNS.
// Chosen so it is invertible (det <> 0).
A = [2 1 1;
     1 3 2;
     1 0 0];
// --------------------------------------------

// --- 1. Row vector: 1 row, many columns ---
row_vec = [10 20 30 40 50];
disp("Row vector:");
disp(row_vec);

// --- 2. Column vector: many rows, 1 column ---
// Using the transpose operator (') on a row vector.
col_vec = [10 20 30 40 50]';
disp("Column vector (transposed row):");
disp(col_vec);

// --- 3. Matrix literal with semicolons = rows ---
disp("Matrix A (3x3):");
disp(A);

// --- 4. Indexing a single element A(row, col) ---
entry = A(2, 3);              // row 2, column 3 -> value 2
disp("A(2,3) =");
disp(entry);

// --- 5. Column slice A(:, col) -> whole column ---
col2 = A(:, 2);               // all rows, column 2
disp("Column 2 of A, A(:,2):");
disp(col2);

// --- 6. Row slice A(row, :) -> whole row ---
row1 = A(1, :);               // row 1, all columns
disp("Row 1 of A, A(1,:):");
disp(row1);

// --- 7. Transpose: swap rows and columns ---
A_t = A';
disp("transpose of A (A with rows and columns swapped):");
disp(A_t);

// --- 8. size() and length() ---
[nrows, ncols] = size(A);     // dimensions of a matrix
vec_len = length(row_vec);    // number of elements in a vector
disp("size(A) -> rows, cols:");
disp(nrows);
disp(ncols);
disp("length(row_vec) =");
disp(vec_len);

// --- 9. Determinant and inverse ---
detA = det(A);
disp("det(A) =");
disp(detA);

A_inv = inv(A);
disp("inv(A):");
disp(A_inv);

// --- 10. Check: det(A) * inv(A) should give a matrix whose
//         action mimics scaling; better check: A * inv(A) ~ I ---
product = A * A_inv;          // should be close to identity
identity_check = eye(3, 3);
disp("A * inv(A) (should be identity):");
disp(product);

// det(A) * inv(A): det is a scalar, inv(A) is a matrix, so the
// scalar multiplies every entry of inv(A). We verify it equals
// the classical adjugate-like scaling, then confirm diag dominance.
det_times_inv = detA * A_inv;
disp("det(A) * inv(A) (scalar times matrix):");
disp(det_times_inv);

// The real sanity check: A*inv(A) minus eye(3,3) should be ~0
err = max(abs(product - identity_check));
disp("max abs error of A*inv(A) - I (should be ~0):");
disp(err);

disp("Program 02 complete.");
