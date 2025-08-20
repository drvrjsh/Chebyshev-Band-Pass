clear; clc; close all;

% Numerator
num = [1.996e6 0 0];

% Denominator
den1 = [1 831.9932 1.2014e7];
den2 = [1 456.5468 3.6183e6];
den = conv(den1, den2);

% Create transfer function
H = tf(num, den);

% Bode plot
figure(1);
bode(H);
grid on;
title('Bode Plot of H(s)');
