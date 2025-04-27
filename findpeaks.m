## -*- texinfo -*-
## @deftypefn {Function File} {[@var{pks} @var{locs}] =} findpeaks (@var{data}, @var{height}, @var{dist})
## Find peaks (local maxima) in data.
##
## @var{pks} is the peak values, @var{locs} is the indices
## of the peaks.
##
## @var{data} is the input data, @var{height} is the minimum
## peak height, and @var{dist} is the minimum distance
## between consecutive peaks.
##
## @var{pks} is a vector of the same kind as @var{data} and
## @var{locs} is a row vector.
##
## Taken from https://stackoverflow.com/a/77410765/22222542
## @end deftypefn
function [pks locs] = findpeaks(data, height, dist)
    narginchk(3, 3);
    nargoutchk(1, 2);

    dist = floor(dist);

    # find all peaks
    locs = regexp(char(sign(diff(reshape(data, 1, []))) + '1'), '21*0') + 1;
    # apply MinPeakHeight
    locs = locs(data(locs) > height);
    # apply MinPeakDistance
    [~, isorted] = sort(data(locs), 'descend');
    n = numel(data);
    idx = false(1, n);
    idx(locs) = true;

    for s = reshape(locs(isorted), 1, [])

        if (idx(s))
            idx(max(s - dist, 1):min(s + dist, n)) = 0;
            idx(s) = 1;
        end

    end

    locs = find(idx);
    pks = data(locs);
end
