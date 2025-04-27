function [v delta_v] = whitenoise(varargin)
    # Specify API
    p = inputParser();
    p.FunctionName = "whitenoise";
    positive_real = @(x) isreal(x) && x > 0;
    p.addRequired("L", positive_real);
    p.addRequired("fname", @ischar);
    p.addOptional("peak_threshold", 1e-5, positive_real);
    vld_tube = @(x) any(strcmp(x, {"symmetric", "asymmetric"}));
    p.addParameter("tube", "symmetric", vld_tube);
    p.addSwitch("disp");
    p.addSwitch("fig");
    p.parse(varargin{:});

    [signal Fs N] = signalread(p.Results.fname);
    [spectrum f] = fftspectrum(signal, Fs, N, true);
    [pks locs] = findpeaks(spectrum, p.Results.peak_threshold, 700 * N / Fs);
    [v n r2 var fhat] = speedofsound(f(locs), p.Results.L, p.Results.tube);

    # Compute 99% CI for regression plotting
    sigma = sqrt(var);
    beta = v / (2 * p.Results.L);
    beta_min = beta - 2.5 * sigma;
    beta_max = beta + 2.5 * sigma;
    fhat_min = n * beta_min;
    fhat_max = n * beta_max;

    # Use 68% CI
    delta_v = 2 * p.Results.L * sigma;

    if p.Results.disp
        printf("v = (%.2f +- %.2f) m/s\n", v, delta_v);
        printf("R2 = %.4f\n", r2);
    end

    if p.Results.fig
        figure;
        plot(f, spectrum);
        hold on;
        plot(f(locs), pks, 'ro');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
        title('Single-Sided Amplitude Spectrum of Signal');
        legend('Spectrum', 'Peaks');
        hold off;

        figure;
        plot(n, f(locs), 'rx');
        hold on;
        plot(n, fhat, 'b-');
        plot(n, fhat_min, 'g--');
        plot(n, fhat_max, 'g--');
        xlabel('Harmonic Number');
        ylabel('Frequency (Hz)');
        title('Harmonic Frequencies');
        legend('Peaks', 'Fit', '99% CI');
        annotation("textbox", [.15 .83 .16 .06], ...
            "string", sprintf("v = %.2f m/s", v), ...
            "horizontalalignment", "center", "verticalalignment", "middle", ...
            "backgroundcolor", [1 1 1], "edgecolor", [1 1 1], ...
            "fontsize", 11);
        hold off;
    end

endfunction
