function [X, n, Sigma2] = Pro2TraceNorm(Z, tau)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% min: 1/2*||Z-X||^2 + ||X||_tr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [S, V, D, Sigma2] = MySVDtau(Z, tau);
% V = max(diag(V) - tau, 0);
% n = sum(V > 0);
% X = S(:, 1:n) * diag(V(1:n)) * D(:, 1:n)';

%% new
[m, n] = size(Z);
% m = max(m, n);
% n = min(m, n);
if 2*m < n
    AAT = Z*Z';
    [S, Sigma2, ~] = svd(AAT);
    Sigma2 = diag(Sigma2);
    V = sqrt(Sigma2);
    tol = max(size(Z)) * eps(double(max(V)));
    n = sum(V > max(tol, tau));
%     info_value = V ./ sum(V(:));
%     cs = cumsum(info_value);
%     V(cs>0.4) = 0; 
    mid = max(V(1:n)-tau, 0) ./ V(1:n) ;
    X = S(:, 1:n) * diag(mid) * S(:, 1:n)' * Z;
    return;
end
if m > 2*n
    [X, n, Sigma2] = Pro2TraceNorm(Z', tau);
    X = X';
    return;
end
[S,V,D] = svd(Z);
Sigma2 = diag(V).^2;
n = sum(diag(V) > tau);
X = S(:, 1:n) * max(V(1:n,1:n)-tau, 0) * D(:, 1:n)';




