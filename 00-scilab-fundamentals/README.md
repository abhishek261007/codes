# 00 — Scilab Fundamentals (Experiment 1)

## Objective

Learn the absolute basics of Scilab — the language used by Scilab 2024.1 on Linux — by running small, self-contained teaching programs. By the end of this experiment you will be able to create variables, work with vectors and matrices, use loops and conditionals, write your own functions, and make labelled plots. Every program prints its key results with `disp()` so you can check them against the theory.

## Theory

**Time vectors.** Almost every signal-processing program starts by creating a time vector such as `t = 0:0.01:2*%pi`. This means "start at 0, step by 0.01, stop at 2*pi". Vectors like this are the x-axis for all your plots, and Scilab functions such as `sin(t)` accept the whole vector at once — no loop needed.

**Vectors vs matrices.** A *vector* is a one-dimensional list of numbers: a row vector `[1 2 3]` has one row and many columns, a column vector `[1 2 3]'` (transpose) has many rows and one column. A *matrix* is two-dimensional: rows are separated by semicolons, columns by spaces, e.g. `A = [2 1 1; 1 3 2; 1 0 0]`. Scilab indexes as `A(row, col)` starting at **1**, not 0. `A(:, 2)` is the whole second column, `A(1, :)` is the whole first row, `A'` is the transpose, and `size(A)` returns `[rows, cols]`.

**Element-wise vs matrix operations.** Scilab follows math notation literally, so the dot matters:

| Operation | Meaning | Example |
|-----------|---------|---------|
| `a + b`, `a - b` | element-wise add/subtract | works for any same-sized arrays |
| `a .* b` | element-wise multiply | `[1 2] .* [3 4]` → `[3 8]` |
| `a ./ b` | element-wise divide | `[4 6] ./ [2 2]` → `[2 3]` |
| `a .^ b` | element-wise power | `[1 2] .^ 2` → `[1 4]` |
| `a * b`  | matrix multiply (linear algebra) | needs inner dimensions to match |
| `a / b`  | matrix right-divide (i.e. `a * inv(b)`) | rarely what a beginner wants |
| `a ^ b`  | matrix power | `A^2` means `A*A`, not squaring each entry |

Plain `*`, `/`, `^` on vectors usually either fail with an *inconsistent dimension* error or silently compute a matrix product. When in doubt while doing signal math, use the dotted operators. `sin(t)`, `cos(t)`, `exp(t)` etc. already operate element-wise on vector arguments.

**Constants and syntax reminders.** `%pi` and `%e` are constants; imaginary unit is `%i`; not-equal is `<>`; logical AND/OR are `&` and `|`; comments start with `//`; statements end with `;` (or newline). Scilab has no `clc`, no `quit`, no `input()`, and indices start at 1.

## Program-by-program summary

| File | Concepts |
|------|----------|
| `01-variables-and-operations.sci` | scalars, integer vs real values, `+ - * / ^`, `%pi`, `%e`, operator precedence, `disp()` with units |
| `02-vectors-and-matrices.sci` | row/column vectors, matrix literals, `A(2,3)`, `A(:,2)`, `A(1,:)`, `A'`, `size()`, `length()`, `det()`, `inv()`, identity check |
| `03-loops.sci` | `for` (sum 1..100, factorial), `while` (countdown), nested `for` (multiplication table), vectorized `sum` comparison |
| `04-conditional-statements.sci` | `if / elseif / else`, `modulo()`, comparison operators `< > <= >= == <>`, logical `&` `|`, `select / case` |
| `05-functions.sci` | in-file `function ... endfunction`, single and multiple outputs, `squareit(x)`, `rect2polar_custom(z)` with `abs`/`atan` |
| `06-plotting.sci` | `scf(n)`, `clf(n)`, `plot(t,y)`, two curves per axes via `plot(t,y1,t,y2)`, `legend`, `xgrid()`, `subplot(2,1,k)` |
| `07-element-wise-operations.sci` | `.* ./ .^` on vectors, contrast with matrix `*`/`^`, inconsistent-dimension error explained, `y = t.*sin(t)` plot |
| `08-working-with-arrays.sci` | single-element and range indexing `v(2:5)`, `find()`, `sum`, `mean`, `max`, `min`, `gsort`, `modulo` alternating pattern |

## How to run

Scilab GUI (interactive):

```scilab
cd("/home/abhishek/scilab-communications-lab/00-scilab-fundamentals")
exec("01-variables-and-operations.sci", -1)
```

The `-1` tells `exec` to run in the current environment without echoing every line. Repeat for any of the 8 files.

From a terminal (non-interactive):

```sh
cd /home/abhishek/scilab-communications-lab/00-scilab-fundamentals
scilab -nw -f 01-variables-and-operations.sci
```

`-nw` disables the GUI (numbers print to the console; figures may need a display). `exec("file.sci", -1)` in a *fresh* Scilab session is the recommended check — each program is self-contained and never relies on variables from another file.

## Expected plots and interpretation

- **Figure 1 (06-plotting.sci):** `sin(t)` and `cos(t)` from 0 to 2π. The sine curve starts at 0 and rises to 1; cosine starts at 1. They are the same shape shifted by π/2 — look for the zero crossings lined up on the grid.
- **Figure 2 (06-plotting.sci):** `sin(t)` vs `sin(t).*cos(t)`. The product curve oscillates twice as fast (it equals `0.5*sin(2t)`) with half the amplitude. Same axes, same grid — note the legend distinguishes both.
- **Figure 3 (06-plotting.sci):** Two stacked subplots. Top: `y = t.^2`, a parabola climbing from 0 to (2π)² ≈ 39.5. Bottom: `y = exp(-t)`, a decaying curve starting at 1 and falling toward 0 — a classic first-order transient response.
- **Figure (07-element-wise-operations.sci):** `y = t.*sin(t)` — amplitude of the sinusoid grows linearly with `t`, because the envelope is `t` itself. Crossings still occur at multiples of π.

Interpreting them: axis labels and titles should always be present (they are, in every program here). If a curve looks wrong, first check whether you used matrix operators where element-wise ones were intended — that is the #1 beginner bug.

## Common mistakes

- **Matrix vs element-wise:** writing `t^2` or `t * sin(t)` instead of `t.^2` / `t .* sin(t)`. For vectors, plain `^` and `*` are matrix operations and will error out ("inconsistent multiplication/addition/...") or compute nonsense.
- **Missing `end`:** every `for`, `if`, `while`, `function`, `select` and `subplot` block needs its matching `end` (`endfunction` for functions). A missing `end` produces a syntax error at the next statement.
- **Wrong not-equal:** Scilab uses `<>` for "not equal", *not* `!=` and not `~=`. `!=` is a syntax error; `~=` does not exist in Scilab either.
- **Forgetting `%` on constants:** `pi` is not predefined — you must write `%pi` (and `%e`, `%i`). Similarly `true`/`false` are `%t`/`%f`.
- **Using `%` for comments:** comments start with `//`, not `%` or `#`.
- **Parentheses for element grouping:** matrix literals use square brackets `[...]`; parentheses are only for indexing `A(i,j)` and precedence `(a+b)*c`.
- **1-based indexing:** `x(1)` is the first element; `x(0)` is an error. `x($)` is the last.

## Viva questions with answers

1. **Q: What is the difference between a row vector and a column vector in Scilab?**
   A: A row vector `[1 2 3]` has dimensions 1×N; a column vector `[1 2 3]'` has dimensions N×1. The transpose operator `'` converts between them.

2. **Q: How do you create a matrix literal, and how are rows separated?**
   A: With square brackets; spaces/tabs separate columns and semicolons separate rows: `A = [1 2; 3 4]` is 2×2.

3. **Q: What does `A(:, 2)` give you?**
   A: The entire second column of `A`. The colon `:` means "all indices in that dimension".

4. **Q: Why does `t^2` fail for a vector `t`, and what should you write instead?**
   A: `^` is the matrix-power operator, so `t^2` would mean `t*t`, which is invalid for a row vector (inner dimensions don't match). Write `t.^2` for element-wise squaring.

5. **Q: What is `%pi` and what happens if you write `pi`?**
   A: `%pi` is the built-in constant π ≈ 3.14159. `pi` alone is just an (undefined) variable name — using it before assignment gives an undefined-variable error.

6. **Q: Write the Scilab not-equal operator.**
   A: `<>`  (example: `if a <> b then ...`). `!=` and `~=` are not valid Scilab.

7. **Q: How many times does `for i = 1:5` run, and what is `i` on the last iteration?**
   A: Five times; `i` takes values 1, 2, 3, 4, 5, so on the last iteration `i = 5`.

8. **Q: What is the difference between `for` and `while`?**
   A: `for` iterates over a known set of values; `while` repeats as long as a condition is true, so it must update that condition inside the loop body or it runs forever.

9. **Q: How do you define a function with two outputs in a Scilab script?**
   A: `function [mag, ph] = rect2polar_custom(z) ... endfunction`, then call it with `[m, p] = rect2polar_custom(3+4*%i)`.

10. **Q: Which command selects an empty figure window in Scilab, and how do you label axes and add a grid?**
    A: `scf(n)` selects figure `n` and `clf(n)` clears it; then `plot(...)`, `xlabel(...)`, `ylabel(...)`, `title(...)`, `legend(...)` and `xgrid()` add the cosmetics.
