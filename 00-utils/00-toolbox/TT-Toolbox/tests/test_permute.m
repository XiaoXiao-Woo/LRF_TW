rng(42);
for i = 1:2
    d = randi(9)+1 %1-8
    n = randi(4,[1,d])
    [1,randi(20,[1,d-1]),1]
    x = tt_rand(n,d,[1,randi(20,[1,d-1]),1])
    size(x.core)
    order = randperm(d);
    tol = 10^(-5*rand());

    yf = permute(reshape(full(x), n),order);
    yn = reshape(full(permute(x, order, tol)),n(order));
    err = yf - yn;
    err = norm(err(:))/norm(yf(:));
    if (err > tol) warning(sprintf('Error (%g) is larger than tolerance (%g)', err, tol)); end;
end

