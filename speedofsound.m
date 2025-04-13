## --*- texinfo -*-
## @deftypefn {Function File} {[@var{v} @var{n} @var{r2} @var{var} @var{fhat}] = } speedofsound (@var{f}, @var{L}, @var{tubetype})
## Compute the speed of sound in a tube using the resonance
## frequencies.
##
## Performs a linear regression of the resonance frequencies
## against the harmonic numbers.  The speed of sound is
## computed from the slope of the regression line. The model
## is:
## @tex
## $$
## f = \frac{vn}{2L},\, n = 1, 2, 3, \ldots\quad\makebox[.405 \linewidth][l]{\textrm{(same type ends)}}
## f = \frac{vn}{4L},\, n = 1, 3, 5, \ldots\quad\makebox[.405 \linewidth][l]{\textrm{(different type ends)}}
## $$
## @end tex
## @ifnottex
## @example
## @group
## f = v * n / (2 * L), n = 1, 2, 3, ... (same type ends)
## f = v * n / (4 * L), n = 1, 3, 5, ... (different type ends)
## @end group
## @end example
## @end ifnottex
## Notice that the model depends on the type of ends of the
## tube. If they are of the same type (open-open or
## closed-closed), the first model is used. If they are of
# different types (open-closed or closed-open), the second
## model is used.
##
## @var{v} is the speed of sound in the tube (in m/s).
## @var{n} is a column vector of harmonic numbers.  @var{r2}
## is the coefficient of determination (R-squared). @var{var}
## is the variance-covariance matrix of the estimated
## coefficients. @var{fhat} are the predicted values of the
## dependent variable.
##
## @var{f} is a column vector of resonance frequencies
## (in Hz).  @var{L} is the length of the tube (in meters).
## @var{tubetype} is either:
## @itemize @bullet
## @item "symmetric" to use the first model
## @item "asymmetric" to use the second model
## @end itemize
##
## @end deftypefn

function [v n r2 var fhat] = speedofsound(f, L, tubetype)
    narginchk(3, 3);
    nargoutchk(1, 5);

    if !iscolumn(f) ||!isreal(f)
        error('speedofsound: f must be a real column vector.');
    end

    if !isscalar(L) ||!isreal(L) || L <= 0
        error('speedofsound: L must be a positive real scalar.');
    end

    switch (tubetype)
        case 'symmetric'
            n = (1:size(f, 1))';
            k = 2;
        case 'asymetric'
            n = 2 * (1:size(f, 1))' - 1;
            k = 4;
        otherwise
            error('speedofsound: harmonics must be either "symmetric" or "asymmetric".');
    end

    [coef, r2, var, ~, fhat] = ols(n, f);
    assert(size(coef), [1, 1]);
    v = coef * L / k;
endfunction
