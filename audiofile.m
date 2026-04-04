pkg load signal

Fs = 48000; % sample rate

% Calculate the approximate range of possible frequencies
% for the given dimension of the tube
% and a speed of sound of 343 m/s

tube_length = 13.878 * 0.01;
tube_diameter = 1.52 * 0.01;
given_v = 343;

% since f = v/2(L + 0.6d) (on a tube with both ends open)

f0 = 343 / (2 * (tube_length + 0.6 * tube_diameter)) - 100% starting freq
f1 = 343 / (2 * (tube_length + 0.6 * tube_diameter)) + 250% ending freq

T = 5; % length of audio file (in sec)
t = 0:1 / Fs:T; % time of each sample
size(t)

k = (f1 - f0) / T; % freq delta per sec

data = 0.2 * sin(2 * pi * (f0 * t + 0.5 * k * t.^2));

audiowrite("test.wav", data, Fs);

% file = fopen("array.cpp", "w");
% data255 = data * 127;
% data2 = chirp(t, f0, T, f1, "linear");
% data255 = data255 + 127;
% fprintf(file, "%.0f,\n", data255);
