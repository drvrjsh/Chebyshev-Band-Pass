clear; clc; close all;

% Numerator
num = [1.996e6 0 0];

% Denominator
den1 = [1 831.9932 1.2014e7];
den2 = [1 456.5468 3.6183e6];
den = conv(den1, den2);

% Create transfer function
H = tf(num, den);

%% Analyze poles and zeros
fprintf('\nPoles & Zeros\n');
poles = pole(H);
zeros = zero(H);

fprintf('Zeros:\n');
for i = 1:length(zeros)
    if imag(zeros(i)) == 0
        fprintf('  z%d = %.4f\n', i, real(zeros(i)));
    else
        fprintf('  z%d = %.4f %+.4fi\n', i, real(zeros(i)), imag(zeros(i)));
    end
end

fprintf('\nPoles:\n');
for i = 1:length(poles)
    if imag(poles(i)) == 0
        fprintf('  p%d = %.4f\n', i, real(poles(i)));
    else
        fprintf('  p%d = %.4f %+.4fi\n', i, real(poles(i)), imag(poles(i)));
    end
end

% Check stability
if all(real(poles) < 0)
    fprintf('\nSystem is STABLE\n');
else
    fprintf('\nSystem is UNSTABLE\n');
end

%% Frequency response
fprintf('\nFrequency Response\n');

% Bode plot
figure(1);
bode(H);
grid on;
title('Bode Plot of H(s)');

% Frequency response data
[mag, phase, w] = bode(H);
mag_db = 20*log10(squeeze(mag));
phase_deg = squeeze(phase);

% Find key frequencies
[max_mag, max_idx] = max(mag_db);
resonant_freq = w(max_idx);

fprintf('\nPeak magnitude: %.2f dB at %.4f rad/s (%.4f Hz)\n', ...
    max_mag, resonant_freq, resonant_freq/(2*pi));

% Nyquist plot
figure(2);
nyquist(H);
grid on;
title('Nyquist Plot of H(s)');

%% Time domain
fprintf('\nTime Domain Analysis\n');

% Step response
figure(3);
subplot(2,2,1);
step(H);
grid on;
title('Step Response');

% Impulse response
subplot(2,2,2);
impulse(H);
grid on;
title('Impulse Response');

% Ramp response (1/s input)
subplot(2,2,3);
t = 0:0.001:2;
u_ramp = t;
y_ramp = lsim(H, u_ramp, t);
plot(t, y_ramp, 'b-', t, u_ramp, 'r--');
xlabel('Time (s)');
ylabel('Amplitude');
title('Ramp Response');
legend('Output', 'Input', 'Location', 'best');
grid on;

% Custom sinusoidal input
subplot(2,2,4);
freq = 100; % Hz
u_sin = sin(2*pi*freq*t);
y_sin = lsim(H, u_sin, t);
plot(t, y_sin, 'b-', t, u_sin, 'r--');
xlabel('Time (s)');
ylabel('Amplitude');
title(['Sinusoidal Response (', num2str(freq), ' Hz)']);
legend('Output', 'Input', 'Location', 'best');
grid on;

%% Additional characteristics
fprintf('\nCharacteristics\n');

% DC gain
dc_gain = dcgain(H);
fprintf('DC Gain: %.6f\n', dc_gain);

% Bandwidth
try
    bw = bandwidth(H);
    fprintf('Bandwidth: %.4f rad/s (%.4f Hz)\n', bw, bw/(2*pi));
catch
    fprintf('Bandwidth calculation not available for this system type\n');
end

% Natural frequencies and damping ratios
[wn, zeta] = damp(H);
fprintf('\nNatural frequencies and damping ratios:\n');
for i = 1:length(wn)
    fprintf('  Mode %d: wn = %.4f rad/s, zeta = %.4f\n', i, wn(i), zeta(i));
end

%% Pole-zero map
figure(4);
pzmap(H);
grid on;
title('Pole-Zero Map');

%% Root locus
figure(5);
rlocus(H);
grid on;
title('Root Locus');

%% Helper functions

% Function to evaluate H(s) at specific frequencies
test_frequencies = [1, 10, 100, 1000, 10000]; % rad/s
fprintf('\nFrequency response at specific points:\n');
for f = test_frequencies
    s = 1j*f;
    H_val = evalfr(H, s);
    mag_db = 20*log10(abs(H_val));
    phase_deg = angle(H_val)*180/pi;
    fprintf('  f = %5d rad/s: |H| = %8.4f dB, ∠H = %8.2f°\n', ...
        f, mag_db, phase_deg);
end

%% Step response characteristics
fprintf('\n=== STEP RESPONSE CHARACTERISTICS ===\n');
try
    step_info = stepinfo(H);
    fprintf('Rise Time: %.6f s\n', step_info.RiseTime);
    fprintf('Settling Time: %.6f s\n', step_info.SettlingTime);
    fprintf('Overshoot: %.4f%%\n', step_info.Overshoot);
    fprintf('Peak: %.6f\n', step_info.Peak);
    fprintf('Peak Time: %.6f s\n', step_info.PeakTime);
catch
    fprintf('Step response characteristics not available\n');
end
