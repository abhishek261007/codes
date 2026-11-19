// =============================================================
// Program 06 - Plotting
// Experiment 1: Scilab Fundamentals
// Objective: Create figures with labelled, gridded plots; use
// legends; and arrange multiple axes with subplot().
// =============================================================

// ---------------- PARAMETERS ----------------
t = 0:0.01:2*%pi;        // time vector, radians 0..2*pi, 201 points
// --------------------------------------------

// --- Figure 1: sin vs cos on the same axes ---
scf(1);                  // select figure window 1
clf(1);                  // clear anything already in it
plot(t, sin(t), t, cos(t));
xlabel("t (radians)");
ylabel("Amplitude");
title("sin(t) and cos(t) over [0, 2*pi]");
legend("sin(t)", "cos(t)", "in_upper_right");
xgrid();                 // light grid to read values easily

disp("Figure 1: sin vs cos plotted.");
disp("sin(0) =");
disp(sin(0));
disp("cos(0) =");
disp(cos(0));

// --- Figure 2: TWO curves on ONE axes via plot(t,y1,t,y2) ---
scf(2);
clf(2);
y1 = sin(t);
y2 = sin(t) .* cos(t);   // element-wise product (see program 07)
plot(t, y1, t, y2);      // two curves, one call, same axes
xlabel("t (radians)");
ylabel("Amplitude");
title("sin(t) and sin(t)*cos(t) on the same axes");
legend("sin(t)", "sin(t).*cos(t)");
xgrid();
disp("Figure 2: two curves on one axes.");

// --- Figure 3: subplot grid 2x1 ---
// subplot(rows, cols, index): index runs left-to-right, top-to-bottom.
scf(3);
clf(3);

subplot(2, 1, 1);        // top half
y_quad = t .^ 2;         // element-wise square of t
plot(t, y_quad);
xlabel("t (radians)");
ylabel("y = t^2");
title("Quadratic: y = t^2");
xgrid();

subplot(2, 1, 2);        // bottom half
y_exp = exp(-t);         // natural exponential decay
plot(t, y_exp);
xlabel("t (radians)");
ylabel("y = exp(-t)");
title("Exponential decay: y = exp(-t)");
xgrid();

disp("Figure 3: subplot(2,1,1) = t^2, subplot(2,1,2) = exp(-t).");
disp("y(0) for exp(-t) should be 1:");
disp(exp(0));
disp("y(2*pi) for t^2 should be (2*pi)^2 =");
disp((2*%pi)^2);

disp("Program 06 complete.");
