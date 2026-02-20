## -*- texinfo -*-
## @deftypefn {Function File} {[@var{coefs} @var{r2} @var{var} @var{s2} @var{yhat}] =} ols (@var{X}, @var{y})
## Compute the Ordinary Least Squares (OLS) regression
## coefficients.
##
## @var{coefs} is the vector of regression coefficients,
## @var{r2} is the coefficient of determination (R-squared),
## @var{var} is the variance-covariance matrix of the
## estimated coefficients, @var{s2} is the standard regression
## error, and @var{yhat} are the predicted values of the
## dependent variable.
##
## @var{X} is the design matrix.  Each row of @var{X} is an
## observation, and each column is a predictor variable
## (i.e. an independent variable).  The first column of
## @var{X} must be a column of ones if the model includes#
## an intercept.  @var{y} is the dependent variable vector
## (i.e. the response variable), containing the observed
## values of the dependent variable.
##
## The dimensions of in/out variables are:
## @itemize @bullet
## @item @var{X} is a matrix of size (n x p), where n is the
## number of observations and p is the number of predictors
## (including the intercept).
## @item @var{y} is a vector of size (n x 1), where n is the
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
##
## X = [ones(size(x)) x]
##
## [coefs r2 var s2 yhat] = ols(X, y)
## @end group
## @end example
## @end deftypefn
function [coefs r2 var s2 yhat] = ols(X, y)
    narginchk(2, 2);
    nargoutchk(1, 5);

    coefs = X \ y;
    yhat = X * coefs;
    ybar = mean(y);
    r2 = sum((yhat - ybar).^2) / sum((y - ybar).^2);
    s2 = norm(y - yhat)^2 / (length(y) - length(coefs));
    var = s2 * inv(X' * X);
endfunction
