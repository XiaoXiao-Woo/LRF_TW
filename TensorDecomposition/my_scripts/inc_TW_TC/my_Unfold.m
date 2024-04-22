function W = my_Unfold(W, dim, i)
%{
example: input: W is a factor, aka G
                dim:size(W); 
                i: permute tensor except ith,
                and reshape tensor to (ith, -1) size of matrix
        
         input: W:2x200x2x13; dim:size(W); i:2
         return: 200x2x2x13->200x2*2*13=200x52
%}

n=1:length(dim); 
n(i)=[]; 
m=zeros(length(dim),1);
m(1)=i;
m(2:end)=n; %2, 1, 3, 4
W = permute(W,m);
W = reshape(W, dim(i), []);
end