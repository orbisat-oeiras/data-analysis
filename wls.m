## -*- texinfo -*-
## @deftypefn {Function File} {[@var{coefs} @var{r2} @var{var} @var{yhat}] =} ols (@var{X}, @var{y}, @var{w})
## Compute the Weighted Least Squares (WLS) regression
## coefficients.
##
## @var{coefs} is the vector of regression coefficients,
## @var{r2} is the coefficient of determination (R-squared),
## @var{var} is the variance-covariance matrix of the
## estimated coefficients, and @var{yhat} are the predicted
## values of the dependent variable.
##
## @var{X} is the design matrix.  Each row of @var{X} is an
## observation, and each column is a predictor variable
## (i.e. an independent variable).  The first column of
## @var{X} must be a column of ones if the model includes#
## an intercept.  @var{y} is the dependent variable vector
## (i.e. the response variable), containing the observed
## values of the dependent variable.  @var{w} is the weight
## vector.  Each element of @var{w} is the weight of the
## corresponding observation in @var{y}, given by the
## inverse of the variance of the corresponding observation.
##
## The dimensions of in/out variables are:
## @itemize @bullet
## @item @var{X} is a matrix of size (n x p), where n is the
## number of observations and p is the number of predictors
## (including the intercept).
## @item @var{y} is a vector of size (n x 1), where n is the
## number of observations.
## @item @var{w} is a vector of size (n x 1), where n is the
## number of observations.
## @item @var{coefs} is a vector of size (p x 1), where p is the
## number of predictors (including the intercept).
## @item @var{r2} is a scalar
## @item @var{var} is a matrix of size (p x p), where p is the
## number of predictors (including the intercept).
## @item @var{s2} is a scalar
## @item @var{yhat} is a vector of size (n x 1), where n is the
## number of observations.
## @end itemize
##
## @example
## @group
## x = (1:10)'
## y_true = 2 * x + 3
## y = y_true + randn(size(x)) * 0.5
## w = 1 ./ (randn(size(y)) * 0.1)
##
## X = [ones(size(x)) x]
##
## [coefs r2 var yhat] = wls(X, y)
## @end group
## @end example
## @end deftypefn
function [coefs r2 var yhat] = wls(X, y, w)
    narginchk(2, 3);
    nargoutchk(1, 5);

    if !ismatrix(X) ||!isvector(y)
        error("wls: X must be a matrix and y must be a vector");
    end

    if size(X, 1) != size(y, 1)
        error("wls: X and y must have the same number of rows");
    end

    if !isreal(X) ||!isreal(y)
        error("wls: X and y must be real-valued matrices");
    end

    if nargin < 3
        w = ones(size(y));
    end

    if !isvector(w) ||!isreal(w)
        error("wls: w must be a real-valued vector");
    end

    if size(w, 1) != size(y, 1)
        error("wls: w must be a vector");
    end

    # Apply a whitening transformation to the data so that
    # left division can be used instead of matrix inversion
    # to solve the normal equations.
    W = diag(sqrt(w));
    Xprime = W * X;
    yprime = W * y;
    coefs = Xprime \ yprime;
    yhat = X * coefs;
    ybar = mean(yprime) / mean(w);
    r2 = sum((yhat - ybar).^2) / sum((y - ybar).^2);
    var = inv(X' * W * X);
endfunction
