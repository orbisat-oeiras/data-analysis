function [v delta_v] = sweep(varargin)
    # Specify API
    p = inputParser();
    p.FunctionName = "sweep";
    positive_real = @(x) isreal(x) && x > 0;
    p.addRequired("L", positive_real);
    p.addRequired("fname", @ischar);
    vld_method = @(x) any(strcmp(x, {"direct", "correlation"}));
    p.addParameter("method", "direct", vld_method);
    p.addParameter("original", "", @ischar);
    p.addParameter("peak_threshold", 1e-5, positive_real);
    positive_int = @(x) isinteger(x) && x > 0;
    p.addParameter("corr_peak", 2, positive_int);
    vld_tube = @(x) any(strcmp(x, {"symmetric", "asymmetric"}));
    p.addParameter("tube", "symmetric", vld_tube);
    p.addSwitch("disp");
    p.addSwitch("fig");
    p.parse(varargin{:});

    [signal Fs N] = signalread(p.Results.fname);
    [spectrum f] = fftspectrum(signal, Fs, N, true);

    switch (p.Results.tube)
        case 'symmetric'
            k = 2;
        case 'asymmetric'
            k = 4;
        otherwise
            error('sweep: tube must be either "symmetric" or "asymmetric".');
    end

    if strcmp(p.Results.method, "direct")
        [pk idx] = max(spectrum);

        v = f(idx) * k * p.Results.L;
        delta_f = Fs / (2 * N);
        delta_v = k * p.Results.L * delta_f;

        if p.Results.disp
            printf("v = (%.2f +- %.2f) m/s\n", v, delta_v);
        end

        if p.Results.fig
            figure;
            plot(f, spectrum);
            hold on;
            plot(f(idx), pk, 'ro');
            xlabel('Frequency (Hz)');
            ylabel('Amplitude');
            title('Single-Sided Amplitude Spectrum of Signal');
            legend('Spectrum', 'Peak');
            annotation("textbox", [.7 .75 .16 .06], ...
                "string", sprintf("v = %.2f \\pm %.2f m/s", v, delta_v), ...
                "horizontalalignment", "center", "verticalalignment", "middle", ...
                "backgroundcolor", [1 1 1], "edgecolor", [1 1 1], ...
                "fontsize", 11);
            hold off;
        end

    else

        if strcmp(p.Results.original, "")
            error("sweep: original audio filename must be provided for correlation method.");
        end

        [signal_o Fs_o N_o] = signalread(p.Results.original);

        if Fs != Fs_o
            error("sweep: mismatched sample rates.");
        end

        N_o = length(signal_o);

        # Compute the spectrum of the original signal
        [spectrum_o f_o] = fftspectrum(signal_o, Fs_o, N_o, 0.001);

        # Ensure the original spectrum is the same length as the new spectrum
        if length(spectrum_o) > length(spectrum)
            spectrum_o = spectrum_o(1:length(spectrum));
            f_o = f_o(1:length(spectrum));
        elseif length(spectrum_o) < length(spectrum)
            spectrum = spectrum(1:length(spectrum_o));
            f = f(1:length(spectrum_o));
        end

        # Compute the cross-correlation between the spectra of the two signals
        cross_corr_spectrum = xcorr(spectrum, spectrum_o);
        # Normalize the cross-correlation spectrum
        cross_corr_spectrum = cross_corr_spectrum / (norm(spectrum) * norm(spectrum_o));
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

        if p.Results.disp
            printf("f_max = %.2f Hz\n", f(idx));
            printf("v = (%.2f +- %.2f) m/s\n", v, delta_v);
        end

        if p.Results.fig
            # Suppress a warning because the spectrum has zero-amplitude components
            warning("off", "Octave:negative-data-log-axis");
            # Plot the spectrum of the original signal
            figure;
            semilogy(f_o, spectrum_o);
            xlabel('Frequency (Hz)');
            ylabel('Amplitude');
            title('Single-Sided Amplitude Spectrum of Original Signal');
            warning("on", "Octave:negative-data-log-axis");

            # Plot the cross-correlation spectrum
            figure;
            plot(f, cross_corr_spectrum);
            # Display the frequency lag in the graph
            hold on;
            plot(f(idx), pk, 'ro');
            xlabel('Frequency (Hz)');
            ylabel('Cross-Correlation Spectrum');
            title('Cross-Correlation Spectrum between Signals');
            legend('Cross-Correlation Spectrum');
            hold off;
        end

    end

endfunction
