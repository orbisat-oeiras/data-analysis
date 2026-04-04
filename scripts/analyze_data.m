function [v delta_v] = analyze_data(varargin)
    p = inputParser();

    % Required Data
    singleOrSeries = @(x) any(strcmp(x, {"single", "series"}));
    p.addRequired("datatype", singleOrSeries);
    positive_real = @(x) isreal(x) && x > 0;
    p.addRequired("L", positive_real);

    % Optional Parameters
    p.addParameter("peak_threshold", 1e-5, positive_real);
    p.addParameter("corr_peak", 2, @(x) isinteger(x) && x > 0);
    p.addParameter("bootcount", "", @ischar);
    p.addParameter("fname", @ischar);
    p.addParameter("cansat_data", "", @ischar);
    p.addParameter("variable", "", @ischar);
    p.addParameter("original", "", @ischar);
    vld_method = @(x) any(strcmp(x, {"direct", "correlation"}));
    p.addParameter("method", "direct", vld_method);
    p.addParameter("regression_type", "ols", @ischar);

    % Switches
    p.addSwitch("disp");
    p.addSwitch("fig");
    p.addSwitch("fig_py");

    p.parse(varargin{:});

    k = 2;

    ## ---
    ## Single Audio Source
    ## ---
    if strcmp(p.Results.datatype, "single")
        filename = p.Results.fname;
        [signal, Fs, N] = signalread(filename);
        [spectrum, f] = fftspectrum(signal, Fs, N, 0.01);

        if strcmp(p.Results.method, "direct")
            [pk, idx] = max(spectrum);

            # Quadratic peak interpolation
            alpha = spectrum(idx - 1);
            beta_ = spectrum(idx);
            gamma_ = spectrum(idx + 1);
            p_shift = 0.5 * (alpha - gamma_) / (alpha - 2 * beta_ + gamma_);

            bin_width = f(2) - f(1);
            exact_f = f(idx) + (p_shift * bin_width);

            v = exact_f * k * (p.Results.L);
            delta_f = Fs / (2 * N);
            delta_v = k * p.Results.L * delta_f;
        endif

        if strcmp(p.Results.method, "correlation")
            error("Correlation with single data source not implemented.");
        endif

        if p.Results.disp
            printf("f_max = %.2f Hz\n", f(idx));
            printf("v = (%.2f +- %.2f) m/s\n", v, delta_v);
        end

        if p.Results.fig
            figure;
            plot(f, spectrum);
            hold on;
            plot(f(idx), pk, 'ro');
            xlabel('Frequency (Hz)');
            ylabel('Amplitude');
            xlim([1000, 1500]);
            title('Single-Sided Amplitude Spectrum of Signal');
            legend('Spectrum', 'Peak');
            annotation("textbox", [.7 .71 .16 .06], ...
                "string", sprintf("v = %.2f \\pm %.2f m/s", v, delta_v), ...
                "horizontalalignment", "center", "verticalalignment", "middle", ...
                "backgroundcolor", [1 1 1], "edgecolor", [1 1 1], ...
                "fontsize", 11);
            annotation("textbox", [.7 .75 .16 .06], ...
                "string", sprintf("f = %.2f \\pm %.2f Hz", f(idx), N / (2 * Fs)), ...
                "horizontalalignment", "center", "verticalalignment", "middle", ...
                "backgroundcolor", [1 1 1], "edgecolor", [1 1 1], ...
                "fontsize", 11);
            hold off;
        end

        if p.Results.fig_py
            save('-mat', 'python/data/cansat_export.mat', 'f', 'spectrum', 'v', 'delta_v');
            printf("Launching python visualizer...");
            system("python3 ./python/plot_cansat.py single");
            pause

        end

    endif

    ## ---
    ## Multiple Audio Sources
    ## ---

    if strcmp(p.Results.datatype, "series")

        if strcmp(p.Results.bootcount, "")
            error("Boot Count should not be empty if datatype is series.");
        endif

        files = dir(sprintf("audio/cansat-sec-mission-%s-*.wav", num2str(p.Results.bootcount)));

        data = zeros(3, length(files));

        if strcmp(p.Results.method, "correlation")

            if strcmp(p.Results.original, "")
                error("sweep: original audio filename must be provided for correlation method.");
            end

            [signal_o Fs_o N_o] = signalread(p.Results.original);

            N_o = length(signal_o);
            # Compute the spectrum of the original signal
            # I put this here at the beginning so it isn't calculated inside the loop hundreds of times
            [spectrum_o f_o] = fftspectrum(signal_o, Fs_o, N_o);

        endif

        for j = 1:length(files)
            currentFileName = fullfile(files(j).folder, files(j).name);
            [signal, Fs, N] = signalread(currentFileName);
            [spectrum, f] = fftspectrum(signal, Fs, N, 0.01);

            [~, name_only, ~] = fileparts(currentFileName);
            parts = strsplit(name_only, '-');
            timestamp_str = parts{end};
            timestamp_num = str2num(timestamp_str);

            if strcmp(p.Results.method, "direct")
                # Not sure if this is a reach, but implemented
                # quadratic interpolation of the peak to estimate the "in-between-FFT-bins" resonance frequency
                [pk, idx] = max(spectrum);
                alpha = spectrum(idx - 1);
                beta_ = spectrum(idx);
                gamma_ = spectrum(idx + 1);
                p_shift = 0.5 * (alpha - gamma_) / (alpha - 2 * beta_ + gamma_);

                bin_width = f(2) - f(1);
                exact_f = f(idx) + (p_shift * bin_width);

                v = exact_f * k * (p.Results.L);
                delta_f = Fs / (2 * N);
                delta_v = k * p.Results.L * delta_f;
                data(1, j) = v;
                data(2, j) = timestamp_num;
                data(3, j) = delta_v;

            else
                # Not yet sure if this works, just copied it from last years' script and
                # haven't had the chance to test it
                [original_spectrum, original_f] = [spectrum_o, f_o];

                if Fs_o != Fs
                    error("Sample rates of recorded data and original must match.");
                endif

                # Ensure the original spectrum is the same length as the new spectrum
                if length(original_spectrum) > length(spectrum)
                    original_spectrum = original_spectrum(1:length(spectrum));
                    original_f = original_f(1:length(spectrum));
                elseif length(original_spectrum) < length(spectrum)
                    spectrum = spectrum(1:length(original_spectrum));
                    f = f(1:length(original_spectrum));
                end

                # Compute the cross-correlation between the spectra of the two signals
                cross_corr_spectrum = xcorr(spectrum, original_spectrum);
                # Normalize the cross-correlation spectrum
                cross_corr_spectrum = cross_corr_spectrum / (norm(spectrum) * norm(original_spectrum));
                # Discard the negative part of the cross-correlation spectrum
                cross_corr_spectrum = cross_corr_spectrum(floor(length(cross_corr_spectrum) / 2) + 1:end);
                # Discard the DC component
                numArtifacts = round(0.02 * N_o / 2);
                cross_corr_spectrum(1:numArtifacts) = 0;
                # Generate the frequency vector for the cross-correlation spectrum
                f = (0:length(cross_corr_spectrum) - 1) * Fs / length(cross_corr_spectrum);
                # Find the maximum correlation frequency
                [pks locs] = findpeaks(cross_corr_spectrum, p.Results.peak_threshold, 700 * N / Fs);
                idx = locs(p.Results.corr_peak);
                pk = cross_corr_spectrum(idx);

                v = f(idx) * k * p.Results.L / p.Results.corr_peak;
                delta_f = Fs / (2 * N);
                delta_v = k * p.Results.L * delta_f;

            endif

        endfor

        if p.Results.fig && strcmp(p.Results.method, "direct")
            # Plot the change of speed of sound in function of time
            speeds = data(1, :);
            timestamps = data(2, :) ./ 1e6;

            figure;
            plot(timestamps, speeds);
            xlabel('Time Elapsed (seconds)');
            ylabel('Speed of sound (m/s)');
            title("CanSat Speed of Sound over time");
            grid on;
        endif

        if p.Results.fig_py && strcmp(p.Results.method, "direct") && strcmp(p.Results.cansat_data, "")
            # Plot with Python the change of speed of sound in function of time
            speeds = data(1, :);
            timestamps = data(2, :) ./ 1e3; # timestamps in milliseconds

            save('-mat', 'python/data/cansat_export.mat', 'speeds', 'timestamps');
            printf("Launching Python Visualizer...");
            system("python3 ./python/plot_cansat.py series");

        endif

        if p.Results.fig_py &&!(strcmp(p.Results.cansat_data, ""))
            # Plot with Python the change of the speed of sound in function of p.Results.variable
            speeds = data(1, :);
            timestamps = data(2, :) ./ 1e3;

            save('-mat', 'python/data/cansat_export.mat', 'speeds', 'delta_v', 'timestamps');
            printf("Launching Python Visualizer...");
            system(sprintf("python3 ./python/plot_cansat.py %s %s %s", p.Results.cansat_data, p.Results.variable, p.Results.regression_type));
        endif

    endif

end
