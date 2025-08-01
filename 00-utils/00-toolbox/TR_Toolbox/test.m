
clear all; clc;
close all;
addpath('corefun');
% %%
% d=4; n=100;
% x= linspace(-1,1,n^d)';
% fun = @(x) (x+1).*sin(100*(x+1).^2);
% % x= linspace(3.001,100,n^d)';
% % fun=@(x) x.^(-1/4).*sin(2*x.^(3/2)/3);
% % x=linspace(10,20,n^d)';
% % fun=@(x) sin(x/4).*cos(x.^2);
% % x=linspace(0.0001,1,n^d);
% % fun=@(x) sin(1./x);
% % x=linspace(0,1,n^d);
% % fun=@(x) 1+sin(1000*x.^3);
% % x=linspace(-100,100,n^d);
% % fun=@(x) sin(x).*cos(x);
% data = fun(x);
% 
% data = reshape(data,[ones(1,d)*n]);
% 
% % data=shiftdim(data,4);
% % figure; plot(data(:));



%%
img=imresize(imread('./data/facade.png'),[256,256]); 
figure; imshow(img);
data=double(img);
% 4     4     4     4     4     4     4     4   3
% 4^8 = 2^8 * 2^8 = 256 * 256
data = reshape(data,[ones(1,8)*4,3]);
d = 4; r=ones(d,1)*2; 


%% Generated data by TR model
% d=4; n=100; r=ones(d,1)*2;  
% node=cell(1,d);
% for i=1:d-1
%    node{i}=randn(r(i),n,r(i+1));
% end
% node{d}=randn(r(d),n,r(1));
% tr=tensor_ring;
% tr=cell2core(tr,node);
% data=full(tr);
% data = reshape(data,ones(1,d)*n);
% figure; plot(data(:));


%% Generated data by TT model
% % % % d=10; n=4; r=[1; ones(d-1,1)*2;1];  
% % % % node=cell(1,d);
% % % % for i=1:d
% % % %    node{i}=rand(r(i),n,r(i+1));
% % % % end
% % % % 
% % % % tt=tt_tensor;
% % % % tt=cell2core(tt,node);
% % % % data=full(tt);
% % % % data = reshape(data,ones(1,d)*n);
% % % % figure; plot(data(:));

%% simple TRD
rand('state', 0);
rnd = rand(4, 5);
save('tr_A.mat', 'rnd');
tr = tensor_ring(rnd,'Tol',1e-2,'Alg','SVD','Rank',[2, 4])
node = tr.node
node1 = reshape(node{1}, [8, 2])
node2 = reshape(node{2}, [10, 2])
resTR = norm(rnd(:)-full(tr))/norm(rnd(:))
rmseTR = norm(rnd(:)-full(tr))/sqrt(numel(rnd))
nopTR = sum(tr.n.*tr.r.*[tr.r(2:end);tr.r(1)])


%% tensor ring
temp=data./std(data(:));
tic;
tr = tensor_ring(temp,'Tol',1e-2,'Alg','SVD','Rank',r)
toc; 
resTR = norm(temp(:)-full(tr))/norm(temp(:))
rmseTR = norm(temp(:)-full(tr))/sqrt(numel(temp))
nopTR = sum(tr.n.*tr.r.*[tr.r(2:end);tr.r(1)])


%% tensor train
temp = data;
tt = tt_tensor(temp, 1e-3)
resTT = norm(temp(:)-full(tt))/norm(temp(:));
nopTT = size(tt.core,1)


%% tt cross
fun = @(subs) data(tt_sub2ind(n*ones(1,d),subs(:)'));
% tt=dmrg_cross(d,n,fun,1e-7);
[tt,Jyl,Jyr,ilocl,ilocr]=greedy2_cross(n*ones(1,d), fun, 1e-7);
norm(data(:)-full(tt))/norm(data(:))
size(tt.core,1)

%% CP
temp = data;
[out] = cp_als(tensor(temp),200, 'init', 'random');
Xhat= double(out);
resCP = norm(Xhat(:)-data(:))/norm(data(:))
nopCP = sum(cellfun(@(x) prod(size(x)), out.U));

%% Bayesian CP
temp = data;
[model] = BCPF(temp, 'init', 'rand', 'maxRank', 100, 'dimRed', 1, 'tol', 1e-1, 'maxiters', 50, 'verbose', 1);
Xhat = double(model.X);
resBCPF = norm(Xhat(:)-data(:))/norm(data(:))
nopBCPF = sum(cellfun(@(x) prod(size(x)), model.X.U))

figure; imshow(uint8(reshape(Xhat,size(img))));

%% Tucker
temp = data;
[out] = tucker_als(tensor(temp),12);
Xhat = double(out);
resTucker = norm(Xhat(:)-data(:))/norm(data(:))
nopTucker = sum(cellfun(@(x) prod(size(x)), out.U)) + prod(size(out.core))


%%

a= randn(1000,10000);

tic; 
[u,s,v] = svd(a,'econ');
toc;
%%
tic; 
[u,s,v] = rsvd(a',10);
toc;
norm(a'-u*s*v','fro')
%%
tic;
[u,s,v] = ksvdPrototype(a', 10, 20);
toc;
norm(a'-u*s*v','fro')

%%
M =a;
% set params
k = 10;
p = 10;
q = 1;
s = 1;


fprintf('rsvd 1..\n');
tic;
[U,Sigma,V] = rsvd_version1(M,k,p,q,s);
toc;
perror = norm(M - U*Sigma*V')/norm(M) * 100

fprintf('rsvd 2..\n');
tic;
[U,Sigma,V] = rsvd_version2(M,k,p,q,s);
toc;
perror = norm(M - U*Sigma*V')/norm(M) * 100

fprintf('rsvd 3..\n');
kstep = 20;
tic;
[U,Sigma,V] = rsvd_version3(M,k,kstep,q,s);
toc;
perror = norm(M - U*Sigma*V')/norm(M) * 100



