function W = my_Fold(W, dim, i)
%{
    input: W:200x52, dim:size(G(num)): 2x200x2x13, i:2
    return: 2x200x2x13
%}
n=1:length(dim); n(i)=[]; m=zeros(length(dim),1);
m(1)=i;  m(2:end)=n; %2,1,4,3
W = reshape(W, dim(m));
W = ipermute(W,m);
end