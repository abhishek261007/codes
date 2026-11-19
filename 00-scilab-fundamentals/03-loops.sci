// =============================================================
// Program 03 - Loops
// Experiment 1: Scilab Fundamentals
// Objective: Practice for loops, while loops and nested loops,
// and understand when vectorization is a better choice.
// =============================================================

// ---------------- PARAMETERS ----------------
limit_sum    = 100;      // upper limit for the sum 1..N
fact_n       = 6;        // compute factorial of this number
table_size   = 5;        // multiplication table is table_size x table_size
countdown_from = 5;      // starting value for the while-loop countdown
// --------------------------------------------

// --- 1. for loop: sum of 1..100 ---
// The accumulator pattern: start at 0, add each term.
total = 0;
for i = 1:limit_sum
    total = total + i;
end
disp("Sum of 1..100 (should be 5050):");
disp(total);

// --- 2. Factorial via a for loop ---
// 6! = 1*2*3*4*5*6 = 720
fact = 1;                     // multiplicative identity
for k = 1:fact_n
    fact = fact * k;
end
disp("Factorial of 6 (should be 720):");
disp(fact);

// --- 3. while loop: countdown ---
// A while loop repeats as long as the condition stays true.
// Use it when the number of iterations is not known in advance.
count = countdown_from;
disp("Countdown:");
while count >= 1
    disp(count);
    count = count - 1;        // MUST update, or infinite loop!
end
disp("Liftoff!");

// --- 4. Nested loops: 5x5 multiplication table ---
// Outer loop walks the rows, inner loop walks the columns.
// We build a matrix M where M(i,j) = i*j.
mult_table = zeros(table_size, table_size);
for i = 1:table_size
    for j = 1:table_size
        mult_table(i, j) = i * j;
    end
end
disp("Multiplication table 1..5 (rows = i, cols = j):");
disp(mult_table);

// Also print row by row so the pattern is readable in the console.
disp("Row-by-row view:");
for i = 1:table_size
    disp(mult_table(i, :));
end

// --- 5. Sum of even numbers up to N (for + modulo) ---
even_sum = 0;
for n = 1:limit_sum
    if modulo(n, 2) == 0      // remainder 0 means even
        even_sum = even_sum + n;
    end
end
disp("Sum of even numbers 1..100 (should be 2550):");
disp(even_sum);

// --- 6. Vectorized comparison note ---
// Loops are easy to read but slower for big data. The same sum
// can be done with vectorized operators (no explicit loop):
vec_sum = sum(1:limit_sum);
disp("Vectorized sum(1:100):");
disp(vec_sum);
// Key idea: Scilab (like MATLAB) works on whole vectors at once,
// so prefer sum/mean/max and element-wise operators (.* ./ .^)
// when possible. Use loops when each step depends on the previous.

disp("Program 03 complete.");
