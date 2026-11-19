// =============================================================
// Program 08 - Working with Arrays
// Experiment 1: Scilab Fundamentals
// Objective: Practice array indexing, range extraction, find(),
// and common aggregation functions: sum, mean, max, min, sort,
// plus modulo for an alternating pattern.
// =============================================================

// ---------------- PARAMETERS ----------------
threshold = 15;                 // cut-off used with find()
x = [4 17 9 23 8 30 12 25];     // sample data vector (8 samples)
alt_n = 10;                     // length of alternating +1/-1 pattern
// --------------------------------------------

// --- 1. Indexing a single element ---
// Scilab indices start at 1 (not 0).
disp("x =");
disp(x);
disp("x(1) = first element =");
disp(x(1));
disp("x(4) = fourth element =");
disp(x(4));
disp("x($) = last element ($ means end) =");
disp(x($));

// --- 2. Range extraction: v(2:5) ---
slice = x(2:5);                // elements 2,3,4,5 -> [17 9 23 8]
disp("x(2:5) =");
disp(slice);

// --- 3. find(x > threshold): indices where condition is true ---
idx = find(x > threshold);
disp("Indices where x > 15:");
disp(idx);
disp("Values at those indices:");
disp(x(idx));

// --- 4. sum: total of all elements ---
total = sum(x);
disp("sum(x) =");
disp(total);                   // 128

// --- 5. mean: arithmetic average ---
avg = mean(x);
disp("mean(x) =");
disp(avg);                     // 16

// --- 6. max and min: extremes and their positions ---
biggest = max(x);
smallest = min(x);
disp("max(x) =");
disp(biggest);                 // 30
disp("min(x) =");
disp(smallest);                // 4
// Locate WHERE the max occurs (useful for peak detection)
[max_val, max_idx] = max(x);
disp("max value and its index:");
disp(max_val);
disp(max_idx);

// --- 7. sort: ascending order ---
// Scilab's built-in sorter is gsort(); mode "i" means increasing.
x_sorted = gsort(x, "g", "i");
disp("sort(x) ascending:");
disp(x_sorted);

// --- 8. modulo for an alternating pattern ---
// modulo(i, 2) is 1 for odd i, 0 for even i.
// (-1)^i flips sign each step -> alternating +1/-1 sequence.
pattern = zeros(1, alt_n);
for i = 1:alt_n
    pattern(i) = (-1)^i;       // -1, +1, -1, +1, ...
end
disp("Alternating pattern (-1)^i for i = 1..10:");
disp(pattern);

// Same thing with modulo: odd positions get +1, even get -1
pattern2 = zeros(1, alt_n);
for i = 1:alt_n
    if modulo(i, 2) == 1
        pattern2(i) = 1;
    else
        pattern2(i) = -1;
    end
end
disp("Alternating pattern via modulo (same shape):");
disp(pattern2);

// --- 9. Alternating sum applied to x ---
// Useful in signal processing (e.g. alternating-sign projections).
alt_weighted = sum(x .* pattern(1:length(x)));
disp("sum(x .* alternating +/-1), length matched to x:");
disp(alt_weighted);

// --- 10. Quick statistics recap ---
disp("--- Recap ---");
disp("count:");
disp(length(x));
disp("sum:");
disp(sum(x));
disp("mean:");
disp(mean(x));
disp("max:");
disp(max(x));
disp("min:");
disp(min(x));

disp("Program 08 complete.");
