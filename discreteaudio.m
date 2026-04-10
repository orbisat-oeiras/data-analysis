Fs = 48000; % sample rate

init_altitude = 180;
max_alt = init_altitude + 1000;

temp_delta = (max_alt - init_altitude) * (6.5/1000);

min_temp = 14;
avg_temp = 20;
max_temp = 28;

L = 20.0468 * sqrt((avg_temp) + 273.15) / (2 * 2600)

v0 = 20.0468 * sqrt((min_temp - (0.50 * min_temp) - temp_delta) + 273.15)
v1 = 20.0468 * sqrt((max_temp + (0.50 * max_temp)) + 273.15)

f0 = v0 / (2 * L)
f1 = v1 / (2 * L)

freq_array = [f0:1:f1 f1:-1:f0];

current_phase = 0;
data = [];
file = fopen("freq.csv", "w");

for f = freq_array
    duration = 20 / f;
    duration_micro = duration * 1e6;
    num_samples = round(duration * Fs);
    t = (0:num_samples - 1) / Fs;
    fprintf(file, "%.0f,%.0f\n", f, duration_micro);

    phase_array = 2 * pi * f * t + current_phase;

    segment = 0.5 * sin(phase_array);
    current_phase = phase_array(end) + 2 * pi * f / Fs;
    data = [data, segment];
endfor

audiowrite("discrete.wav", data, Fs)
