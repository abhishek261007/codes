// =============================================================
// Program 04 - Conditional Statements
// Experiment 1: Scilab Fundamentals
// Objective: Learn if/elseif/else branching, the modulo operator,
// comparison and logical operators, and Scilab's select/case
// (switch-like) construct.
// =============================================================

// ---------------- PARAMETERS ----------------
sample_number = -7;      // used for the sign demo
sample_mark   = 73;      // percentage mark, used for banding
even_test     = 42;      // used for even/odd check
in_range_val  = 55;      // used for the in-range check
range_lo      = 0;       // lower bound of the valid range
range_hi      = 100;     // upper bound of the valid range
menu_choice   = 2;       // used for select/case demo
// --------------------------------------------

// --- 1. Sign of a number with if/elseif/else ---
// Only ONE branch runs; the rest are skipped.
if sample_number > 0
    disp("The number is positive.");
elseif sample_number < 0
    disp("The number is negative.");
else
    disp("The number is zero.");
end

// --- 2. Even or odd via modulo ---
// modulo(x, 2) gives the remainder after division by 2.
if modulo(even_test, 2) == 0
    disp("42 is even.");
else
    disp("42 is odd.");
end

// --- 3. Grade-like banding of a mark ---
// 90+ A, 75+ B, 60+ C, 40+ D, else F (fail).
// Tested top-down: the FIRST true condition wins.
if sample_mark >= 90
    grade = "A";
elseif sample_mark >= 75
    grade = "B";
elseif sample_mark >= 60
    grade = "C";
elseif sample_mark >= 40
    grade = "D";
else
    grade = "F";
end
disp("Mark 73 maps to grade:");
disp(grade);

// --- 4. Comparison operators ---
// <  >  <=  >=  ==  <>  (note: <> means "not equal", NOT !=)
a = 5;
b = 8;
disp("5 < 8   ->");
disp(a < b);               // T (true = 1)
disp("5 > 8   ->");
disp(a > b);               // F (false = 0)
disp("5 <= 5  ->");
disp(a <= 5);              // T
disp("5 >= 8  ->");
disp(a >= b);              // F
disp("5 == 5  ->");
disp(a == 5);              // T
disp("5 <> 8  ->");
disp(a <> b);              // T (not equal)

// --- 5. Logical AND: in-range check ---
// & means AND, | means OR. Both sides must be true for &.
if in_range_val >= range_lo & in_range_val <= range_hi
    disp("Value 55 is inside the range [0, 100].");
    in_range = %t;
else
    disp("Value is OUTSIDE the range.");
    in_range = %f;
end
disp("in_range flag (1 = true, 0 = false):");
disp(in_range);

// --- 6. Logical OR example: extreme values ---
x = 150;
if x < 0 | x > 100
    disp("x is outside 0..100 (OR condition triggered).");
else
    disp("x is within 0..100.");
end

// --- 7. select/case: Scilab's switch statement ---
// select expr ... case value ... end. Matches the FIRST equal case.
select menu_choice
    case 1
        action = "You chose: view signal plot";
    case 2
        action = "You chose: compute FFT";
    case 3
        action = "You chose: export results";
    else
        action = "Invalid choice";
end
disp("select/case result for choice 2:");
disp(action);

// --- 8. Combining everything: classify a temperature ---
temp_c = 36.5;             // body temperature in Celsius
if temp_c >= 37.5
    status = "fever";
elseif temp_c >= 36.0
    status = "normal";
else
    status = "low";
end
disp("Temperature 36.5 C classified as:");
disp(status);

disp("Program 04 complete.");
