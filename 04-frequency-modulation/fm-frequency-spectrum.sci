// =============================================================
// Program 04.6 - FM Frequency Spectrum: beta = 5 vs beta = 0.5
// Experiment 4: FM Transmission and Reception
// Objective: Plot the single-sided FFT magnitude of FM with
//            beta = 5 and beta = 0.5 on subplots sharing the
//            frequency axis, mark the sideband spacing (fm),
//            disp the peak bins for both, and caption the rule
//            "significant sideband pairs ~ beta + 1".
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz (sideband spacing)
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
Tdur = 0.4;            // 0.4 s -> FFT bin spacing = 2.5 Hz
N    = round(fs * Tdur);
beta_wide = 5;         // wideband case
beta_nb   = 0.5;       // almost-narrowband case
// --------------------------------------------

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);

// Phase-integration FM for a given beta
function s = make_fm(beta_val)
    kf_loc = beta_val * fm / Am;
    phase  = 2 * %pi * fc * t + 2 * %pi * kf_loc * cumsum(m) / fs;
    s      = Ac * cos(phase);
endfunction

function P = single_sided_mag(x)
    S = fft(x);
    L = length(x);
    P = abs(S(1:floor(L/2)+1));
    if modulo(L, 2) == 0 then
        P(2:$-1) = 2 * P(2:$-1) / L;
        P(1) = P(1) / L;
        P($) = P($) / L;
    else
        P(2:$) = 2 * P(2:$) / L;
        P(1) = P(1) / L;
    end
endfunction

function fk = peak_freqs(P, n_keep)
    L = length(P);
    loc = find(P(2:$-1) > P(1:$-2) & P(2:$-1) >= P(3:$)) + 1;
    if length(loc) == 0 then
        loc = 1;
    end
    [sm, order] = gsort(P(loc), "g", "d");
    n_keep = min(n_keep, length(loc));
    bins = loc(order(1:n_keep));
    fk   = (bins - 1) * fs / N;
endfunction

s_wide = make_fm(beta_wide);
s_nb   = make_fm(beta_nb);
P_wide = single_sided_mag(s_wide);
P_nb   = single_sided_mag(s_nb);
f      = (0:floor(N/2)) * fs / N;

// Peak lists (largest 6 for wideband, largest 4 for narrowband)
pk_wide = peak_freqs(P_wide, 6);
pk_nb   = peak_freqs(P_nb, 4);

scf(1);
clf(1);
subplot(2,1,1);
plot(f, P_wide);
ylabel("Magnitude (V)");
title("FM spectrum, beta = 5 (wideband): many Bessel sidebands, spacing = fm = 10 Hz");
xgrid();
subplot(2,1,2);
plot(f, P_nb);
xlabel("Frequency (Hz)");
ylabel("Magnitude (V)");
title("FM spectrum, beta = 0.5 (almost narrowband): carrier + 1-2 weak sideband pairs");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 4 / fm-frequency-spectrum - KEY RESULTS");
mprintf("beta = 5   peak frequencies (Hz): ");
for kf_i = 1:length(pk_wide)
    mprintf("%f  ", pk_wide(kf_i));
end
mprintf("\n");
mprintf("beta = 0.5 peak frequencies (Hz): ");
for kf_i = 1:length(pk_nb)
    mprintf("%f  ", pk_nb(kf_i));
end
mprintf("\n");
mprintf("Rule of thumb: number of significant sideband pairs ~ beta + 1\n");
mprintf("  beta = 5   -> ~6 pairs visible (n = 0..6)\n");
mprintf("  beta = 0.5 -> ~1-2 pairs (narrowband behaviour)\n");
mprintf("Sidebands sit at fc +/- n*fm = 200 +/- n*10 Hz. Carrier power falls as J_0(beta)^2.\n");
mprintf("Carson bandwidth: beta=5 -> %f Hz ; beta=0.5 -> %f Hz\n", 2*(beta_wide+1)*fm, 2*(beta_nb+1)*fm);
