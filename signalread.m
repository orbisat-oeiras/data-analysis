## -*- texinfo -*-
## @deftypefn {Function File} {[@var{signal} @var{Fs} @var{N} @var{t}] =} read_audio (@var{fname})
## Read a signal from an audio file.
##
## @var{signal} is the audio signal, @var{Fs} is the sampling
## frequency, @var{N} is the number of samples, and @var{t}
## is the time vector.
##
## If the audio file is stereo, @var{signal} contains only
## the first channel, as a column vector.
##
## @example
## @group
## [signal Fs N t] = signalread('audio.wav');
##
## figure();
## plot(t(1:N), signal(1:N));
## xlabel('t (seconds)');
## ylabel('Signal');
## @end group
## @end example
##
## @code{audioread} is used internally to read the audio file.
##
## @seealso {audioread}
## @end deftypefn
function [signal Fs N t] = signalread(fname)
    narginchk(1, 1);
    nargoutchk(1, 4);

    if !ischar(fname) &&!isstring(fname)
        error("signalread: fname must be a string or character array");
    end

    [signal Fs] = audioread(fname);
    signal = signal(:, 1);
    N = size(signal, 1);
    t = (0:N - 1) / Fs;
endfunction
