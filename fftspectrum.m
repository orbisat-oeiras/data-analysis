## -*- texinfo -*-
## @deftypefn {Function File} {[@var{spectrum} @var{f}] =} fftspectrum (@var{signal}, @var{Fs}, @var{N})
## @deftypefnx {Function File} {[@var{spectrum} @var{f}] =} fftspectrum (@var{signal}, @var{Fs}, @var{N}, @var{removeArtifacts})
## Compute the single-sided amplitude spectrum of a signal
## using FFT.
##
## @var{spectrum} is the single-sided amplitude spectrum of
## the signal (column vector).  @var{f} is the frequency
## (column) vector, which is useful for plotting.
##
## If @var{removeArtifacts} is set to true, the initial
## portion of the spectrum, which usually contains artifacts
## resulting from the FFT, is set to zero. If @var{removeArtifacts}
## is set to a number between 0 and 1, the corresponding
## fraction of the spectrum is set to zero.
##
## @var{signal} is the input signal, @var{Fs} is the
## sampling frequency, @var{N} is the number of samples
## in the signal.
##
## @example
## @group
## [spectrum f] = fftspectrum(signal, Fs, N);
##
## figure();
## plot(f, spectrum);
## xlabel('Frequency (Hz)');
## ylabel('Amplitude');
## title('Single-Sided Amplitude Spectrum of Signal');
## @end group
## @end example
##
## @seealso {fft}
## @end deftypefn
function [spectrum f] = fftspectrum(signal, Fs, N, removeArtifacts = false)
    narginchk(3, 4);
    nargoutchk(1, 2);

    Y = fft(signal);
    spectrum = abs(Y(1:N / 2 + 1) / N);
    f = Fs * (0:(N / 2))' / N;

    if isbool(removeArtifacts)

        if removeArtifacts
            numArtifacts = round(0.05 * N / 2);
            spectrum(1:numArtifacts) = 0;
        end

    elseif isscalar(removeArtifacts) && isreal(removeArtifacts) && removeArtifacts > 0 && removeArtifacts < 1
        numArtifacts = round(removeArtifacts * N / 2);
        spectrum(1:numArtifacts) = 0;
    else
        error("fftspectrum: removeArtifacts must be a boolean or a number between 0 and 1");
    end

endfunction
