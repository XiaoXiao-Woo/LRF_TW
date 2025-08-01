function t = tensor_ring(varargin)


% Tensor Ring toolbox
% written by Qibin Zhao, BSI, RIKEN

if (nargin == 0)
    t.d    = 0;
    t.r    = 0;
    t.n    = 0;
    t.node = 0;                    % empty tensor
    t = class(t, 'tensor_ring');
    return;
end

ip = inputParser;
ip.addParamValue('Tol', 1e-6, @isscalar);
ip.addParamValue('Alg', 'SVD', @ischar);
ip.addParamValue('Rank', [], @ismatrix);
ip.addParamValue('MaxIter', 20, @isscalar);
ip.parse(varargin{2:end});

Tol = ip.Results.Tol;
Alg = ip.Results.Alg;
Rank = ip.Results.Rank;
MaxIter = ip.Results.MaxIter;


rng('default');

if is_array(varargin{1})
    t=tensor_ring;
    if strcmp(Alg,'SVD')
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        node=cell(1,d);
        r = ones(d,1);
        ep=Tol/sqrt(d);
        for i=1:d-1
            if i==1
                c=reshape(c,[n(i),numel(c)/n(i)]);
                [u,s,v]=svd(c,'econ');
                s=diag(s);
                rc=my_chop2(s,sqrt(2)*ep*norm(s));
                %                 rc=size(u,2);
                temp=cumprod(factor(rc));
                [~,idx]=min(abs(temp-sqrt(rc)));
                %                 r(i)=temp(idx); r(i+1)=rc/r(i);
                r(i+1)=temp(idx); r(i)=rc/r(i+1);
                u=u(:,1:r(i)*r(i+1));
                u=reshape(u,[n(i),r(i+1),r(i)]);
                node{i}=permute(u,[3,1,2]);
                s=s(1:r(i)*r(i+1));
                v=v(:,1:r(i)*r(i+1));
                v=v*diag(s);
                v=v';
%                 u=u
%                 s=s
%                 vv=v'
                v=reshape(v,[r(i+1),r(i),prod(n(2:end))]);
                c=permute(v,[1,3,2]);
            else
                m=r(i)*n(i); c=reshape(c,[m,numel(c)/m]);
                [u,s,v]=svd(c,'econ');
                s=diag(s); r1=my_chop2(s,ep*norm(s));
                r(i+1)=max(r1,1);
                u=u(:,1:r(i+1));
                node{i}=reshape(u,[r(i),n(i),r(i+1)]);
                v=v(:,1:r(i+1)); s=s(1:r(i+1));
                v=v*diag(s);
%                 u=u
%                 s=s
%                 v=v
                c=v';
            end
        end
        node{d} = reshape(c,[r(d),n(d),r(1)]);
%         c = reshape(c, [10, 2]);
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    if strcmp(Alg,'rSVD')
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        node=cell(1,d);
        r = ones(d,1);
        ep=Tol/sqrt(d);
        nc_rSVD = 6;
        for i=1:d-1
            if i==1
                c=reshape(c,[n(i),numel(c)/n(i)]);
                nc = min(nc_rSVD,n(i));
                [v,s,u]=rsvd(c',nc);
                %                 [v,s,u] = rsvd_version2(c',nc,nc,1,1);
                
                s=diag(s);
                rc=my_chop2(s,sqrt(2)*ep*norm(c(:)));
                
                temp=cumprod(factor(rc));
                [~,idx]=min(abs(temp-sqrt(rc)));
                %                 r(i)=temp(idx); r(i+1)=rc/r(i);
                r(i+1)=temp(idx); r(i)=rc/r(i+1);
                u=u(:,1:r(i)*r(i+1));
                u=reshape(u,[n(i),r(i+1),r(i)]);
                node{i}=permute(u,[3,1,2]);
                s=s(1:r(i)*r(i+1));
                v=v(:,1:r(i)*r(i+1));
                v=v*diag(s);
                v=v';
                v=reshape(v,[r(i+1),r(i),prod(n(2:end))]);
                c=permute(v,[1,3,2]);
            else
                m=r(i)*n(i); c=reshape(c,[m,numel(c)/m]);
                nc = min(nc_rSVD,m);
                [v,s,u]=rsvd(c',nc);
                %                 [v,s,u] = rsvd_version2(c',nc,nc,1,1);
                
                s=diag(s); r1=my_chop2(s,ep*norm(c(:)));
                
                r(i+1)=max(r1,1);
                u=u(:,1:r(i+1));
                node{i}=reshape(u,[r(i),n(i),r(i+1)]);
                v=v(:,1:r(i+1)); s=s(1:r(i+1));
                v=v*diag(s);
                c=v';
            end
        end
        node{d} = reshape(c,[r(d),n(d),r(1)]);
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    if strcmp(Alg,'CUR')   % Does not work
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        node=cell(1,d);
        r = ones(d,1);
        ep=Tol/sqrt(d);
        nc_cur = 6;
        for i=1:d-1
            if i==1
                c=reshape(c,[n(i),numel(c)/n(i)]);
                nr = min(nc_cur,n(i));
                nc = floor(size(c,2)*0.01);
                [u, s, v] = curPrototype(c, nr, size(c,1));
                %                 [u, s, v] = curFaster(c, nc, nc);
                
                rc=size(u,2);
                temp=cumprod(factor(rc));
                [~,idx]=min(abs(temp-sqrt(rc)));
                %                 r(i)=temp(idx); r(i+1)=rc/r(i);
                r(i+1)=temp(idx); r(i)=rc/r(i+1);
                
                u=reshape(u,[n(i),r(i+1),r(i)]);
                node{i}=permute(u,[3,1,2]);
                
                v=s*v;
                v=reshape(v,[r(i+1),r(i),prod(n(2:end))]);
                c=permute(v,[1,3,2]);
            else
                m=r(i)*n(i); c=reshape(c,[m,numel(c)/m]);
                nr = min(nc_cur,n(i));
                nc = floor(size(c,2)*0.01);
                [u, s, v] = curPrototype(c, nr, size(c,1));
                %                 [u, s, v] = curFaster(c, nc, nc);
                
                r(i+1)=max(size(u,2),1);
                node{i}=reshape(u,[r(i),n(i),r(i+1)]);
                c=s*v;
            end
        end
        node{d} = reshape(c,[r(d),n(d),r(1)]);
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    
    if strcmp(Alg,'ALS')
        maxit=MaxIter;
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        node=cell(1,d);
        r=Rank(:);
        for i=1:d-1
            node{i}=randn(r(i),n(i),r(i+1));
        end
        node{d}=randn(r(d),n(d),r(1));
        od=[1:d]';
        err=1;
        for it=1:maxit*d
            err0=err;
            if it>1
                c=shiftdim(c,1);
                od=circshift(od,-1);
            end
            c=reshape(c,n(od(1)),numel(c)/n(od(1)));
            b=node{od(2)};
            for k=3:d
                j=od(k);
                br=node{j};
                br=reshape(br,[r(j),numel(br)/r(j)]);
                b=reshape(b,[numel(b)/r(j),r(j)]);
                b=b*br;
            end
            b=reshape(b,[r(od(2)),prod(n(od(2:end))),r(od(1))]);
            b=permute(b,[1,3,2]);
            b=reshape(b,[r(od(2))*r(od(1)), prod(n(od(2:end)))]);
            a=c/b;
            err=norm(c-a*b,'fro')/norm(c(:));
            a=reshape(a,[n(od(1)),r(od(2)),r(od(1))]);
            node{od(1)}=permute(a,[3,1,2]);
            s=norm(node{od(1)}(:));
            node{od(1)}=node{od(1)}./s;
            
            fprintf('it:%d, err=%f\n',it,err);
            if abs(err0-err)<=1e-3 && it>=2*d && err<=Tol
                break;
            end
            c=reshape(c,n(od)');
        end
        node{od(1)}=node{od(1)}.*s;
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    if strcmp(Alg,'ALSAR')
        warning('off');
        swithch=0;
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        % Adjustable parameters
        maxit=MaxIter;   %10
        ratio=0.01/d;  %0.01/d
        
        node=cell(1,d);
        r=ones(d,1);
        for i=1:d-1
            node{i}=randn(r(i),n(i),r(i+1));
        end
        node{d}=randn(r(d),n(d),r(1));
        od=[1:d]';
        for it=1:maxit*d
            if it>1
                c=shiftdim(c,1);
                od=circshift(od,-1);
            end
            
            c=reshape(c,n(od(1)),numel(c)/n(od(1)));
            b=node{od(2)};
            for k=3:d
                j=od(k);
                br=node{j};
                br=reshape(br,[r(j),numel(br)/r(j)]);
                b=reshape(b,[numel(b)/r(j),r(j)]);
                b=b*br;
            end
            b=reshape(b,[r(od(2)),prod(n(od(2:end))),r(od(1))]);
            b=permute(b,[1,3,2]);
            b=reshape(b,[r(od(2))*r(od(1)), prod(n(od(2:end)))]);
            a=c/b;
            err0=norm(c-a*b,'fro')/norm(c(:));
            a=reshape(a,[n(od(1)),r(od(2)),r(od(1))]);
            node{od(1)}=permute(a,[3,1,2]);
            
            
            r(od(2))=r(od(2))+1;
            node{od(2)}(r(od(2)),:,:)=mean(node{od(2)}(:))+std(node{od(2)}(:)).*randn(n(od(2)),r(od(3)));
            b=node{od(2)};
            for k=3:d
                j=od(k);
                br=node{j};
                br=reshape(br,[r(j),numel(br)/r(j)]);
                b=reshape(b,[numel(b)/r(j),r(j)]);
                b=b*br;
            end
            b=reshape(b,[r(od(2)),prod(n(od(2:end))),r(od(1))]);
            b=permute(b,[1,3,2]);
            b=reshape(b,[r(od(2))*r(od(1)), prod(n(od(2:end)))]);
            a=c/b;
            err1=norm(c-a*b,'fro')/norm(c(:));
            if (err0-err1)/(err0) > ratio*(err0-Tol)/err0 && err0>Tol
                a=reshape(a,[n(od(1)),r(od(2)),r(od(1))]);
                node{od(1)}=permute(a,[3,1,2]);
                err0 =err1;
                swithch =0;
            else
                node{od(2)}(r(od(2)),:,:)=[];
                r(od(2))=r(od(2))-1;
                swithch=1;
            end
            
            s=norm(node{od(1)}(:));
            node{od(1)}=node{od(1)}./s;
            fprintf('it:%d, err=%f\n',it,err0);
            if err0<=Tol && it>=2*d && swithch ==1
                break;
            end
            c=reshape(c,n(od)');
        end
        
        node{od(1)}=node{od(1)}.*s;
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    if strcmp(Alg,'BALS')
        maxit=MaxIter;
        c=varargin{1};
        n = size(c);
        n = n(:);
        d = numel(n);
        node=cell(1,d);
        r=ones(d,1);
        for i=1:d-1
            node{i}=randn(r(i),n(i),r(i+1));
        end
        node{d}=randn(r(d),n(d),r(1));
        od=[1:d]';
        for it=1:maxit*d
            if it>1
                c=shiftdim(c,1);
                od=circshift(od,-1);
            end
            
            c=reshape(c,n(od(1))*n(od(2)),numel(c)/(n(od(1))*n(od(2))));
            b=node{od(3)};
            for k=4:d
                j=od(k);
                br=node{j};
                br=reshape(br,[r(j),numel(br)/r(j)]);
                b=reshape(b,[numel(b)/r(j),r(j)]);
                b=b*br;
            end
            b=reshape(b,[r(od(3)),prod(n(od(3:end))),r(od(1))]);
            b=permute(b,[1,3,2]);
            b=reshape(b,[r(od(3))*r(od(1)), prod(n(od(3:end)))]);
            a=c/b;
            err0=norm(c-a*b,'fro')/norm(c(:));
            
            a=reshape(a,[n(od(1)),n(od(2)),r(od(3)),r(od(1))]);
            a=permute(a,[4 1 2 3]);
            a=reshape(a, [r(od(1))*n(od(1)), n(od(2))*r(od(3))]);
            [u,s,v]=svd(a,'econ');
            s=diag(s);
            
            r1=my_chop2(s,max([1/sqrt(d)*err0, Tol/sqrt(d)])*norm(s));
            
            %             rt= find(abs(diff(s.^2))<=(Tol*norm(s))^2);
            %             rt= find(abs(diff(s.^2))./(s(1:end-1).^2) <=Tol^2);
            %             r1=my_chop2(s, Tol/sqrt(d)*norm(s));
            
            
            %%----------------linear search----------------------------
            %             [~,r1]=max(abs(diff(s))./norm(s(1:end-1)));
            %             [~,r0]=max(abs(diff(diff(s))));
            %             r1=1;
            %             while r1<numel(s)
            %                 anew= u(:,1:r1)*diag(s(1:r1))*v(:,1:r1)';
            %                 anew=reshape(anew,[r(od(1)),n(od(1)), n(od(2)),r(od(3))]);
            %                 anew=permute(anew,[2 3 4 1]);
            %                 anew=reshape(anew,[n(od(1))*n(od(2)),r(od(3))*r(od(1))]);
            %                 err1=norm(c-anew*b)/norm(c(:));
            %
            %                 if  it<2*d && r1>=r0+1;
            %                     break;
            %                 end
            %                 if err1<max([Tol/d+err0, err0*Tol+err0])
            %                     break;
            %                 end
            %                 r1=r1+1;
            %             end
            %%----------------------------------------------------------
            %             if ~isempty(rt)
            %                 r1=min(r1,rt(1));
            %             end
            r(od(2))= max(r1,1);
            %             r(od(2))= min(r1,r(od(2))+1);
            u=u(:,1:r(od(2)));
            s=s(1:r(od(2)));
            v=v(:,1:r(od(2)));
            v=v*diag(s); v=v';
            node{od(1)}=reshape(u,[r(od(1)),n(od(1)),r(od(2))]);
            node{od(2)}=reshape(v,[r(od(2)),n(od(2)),r(od(3))]);
            
            
            fprintf('it:%d, err=%6f\n',it,err0);
            if err0<=Tol && it>=2*d
                anew=reshape(node{od(1)},[r(od(1))*n(od(1)),r(od(2))])*reshape(node{od(2)},[r(od(2)),n(od(2))*r(od(3))]);
                anew=reshape(anew,[r(od(1)),n(od(1)), n(od(2)),r(od(3))]);
                anew=permute(anew,[2 3 4 1]);
                anew=reshape(anew,[n(od(1))*n(od(2)),r(od(3))*r(od(1))]);
                err1=norm(c-anew*b,'fro')/norm(c(:));
                if err1<=Tol
                    break;
                end
                %                  break;
            end
            c=reshape(c,n(od)');
        end
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    if strcmp(Alg,'BALS2')
        maxit=MaxIter;
        
        c=varargin{1};
        trsvd=tensor_ring(c,'Tol',Tol, 'Alg','SVD');
        
        n = size(c);
        n = n(:);
        d = numel(n);
        node =trsvd.node;
        r=trsvd.r;
        od=[1:d]';
        err1 = Tol;
        for it=1:maxit*d
            if it>1
                c=shiftdim(c,1);
                od=circshift(od,-1);
            end
            
            c=reshape(c,n(od(1))*n(od(2)),numel(c)/(n(od(1))*n(od(2))));
            b=node{od(3)};
            for k=4:d
                j=od(k);
                br=node{j};
                br=reshape(br,[r(j),numel(br)/r(j)]);
                b=reshape(b,[numel(b)/r(j),r(j)]);
                b=b*br;
            end
            b=reshape(b,[r(od(3)),prod(n(od(3:end))),r(od(1))]);
            b=permute(b,[1,3,2]);
            b=reshape(b,[r(od(3))*r(od(1)), prod(n(od(3:end)))]);
            a=c/b;
            err0=norm(c-a*b,'fro')/norm(c(:));
            
            a=reshape(a,[n(od(1)),n(od(2)),r(od(3)),r(od(1))]);
            a=permute(a,[4 1 2 3]);
            a=reshape(a, [r(od(1))*n(od(1)), n(od(2))*r(od(3))]);
            [u,s,v]=svd(a,'econ');
            s=diag(s);
            
            r1=my_chop2(s,max([1/sqrt(d)*err1, Tol/sqrt(d)])*norm(s));
            
            
            %             r(od(2))= min(r1,r(od(2))+1);
            r(od(2))= max(r1,1);
            u=u(:,1:r(od(2)));
            s=s(1:r(od(2)));
            v=v(:,1:r(od(2)));
            v=v*diag(s); v=v';
            node{od(1)}=reshape(u,[r(od(1)),n(od(1)),r(od(2))]);
            node{od(2)}=reshape(v,[r(od(2)),n(od(2)),r(od(3))]);
            
            
            
            anew=reshape(node{od(1)},[r(od(1))*n(od(1)),r(od(2))])*reshape(node{od(2)},[r(od(2)),n(od(2))*r(od(3))]);
            anew=reshape(anew,[r(od(1)),n(od(1)), n(od(2)),r(od(3))]);
            anew=permute(anew,[2 3 4 1]);
            anew=reshape(anew,[n(od(1))*n(od(2)),r(od(3))*r(od(1))]);
            err1=norm(c-anew*b,'fro')/norm(c(:));
            
            fprintf('it:%d, err=%6f\n',it,err0);
            if err0<=Tol && it>=d
                
                if err1<=Tol
                    break;
                end
                %                  break;
            end
            c=reshape(c,n(od)');
        end
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    
    if strcmp(Alg,'SGD')
        rng('default');
        lrate = 0.01;    % learning rate 
        momentum = 0.1;  % forget rate
        c=varargin{1};
        n=size(c);
        n=n(:);
        d=numel(n);
        node=cell(1,d);
        gradnode=cell(1,d);
        r=Rank(:);
        for i=1:d-1
            node{i}=randn(r(i),n(i),r(i+1));
            gradnode{i}=zeros(r(i),n(i),r(i+1));
        end
        node{d}=randn(r(d),n(d),r(1));
        gradnode{d}=zeros(r(d),n(d),r(1));
        
        for i=1:d
          node{i} = node{i}./max(abs(node{i}(:))); 
        end
        
       
        rmse=[];
        perr = ones(1,1000); it=0;
        while  sqrt(mean(perr.^2)) > Tol
            
            it = it +1;
            % sample one tensor entry
            for j=1:d
                I(j)=randsample(n(j),1);
            end
            % compute stochastic gradient
            for j=1:d
                b = 1;
                for k=[j+1:d,1:j-1]
                    b = squeeze(b) * squeeze(node{k}(:,I(k),:));
                end
                if j==1
                    chat = trace(squeeze(node{j}(:,I(j),:))*squeeze(b));
                    sidx = num2cell(I);
                    perr = circshift(perr,1);
                    perr(1) = chat - c(sidx{:});
                end
                gradnode{j}(:,I(j),:) = momentum * squeeze(gradnode{j}(:,I(j),:))+ lrate*(b'*perr(1));              
            end
            
            % gradient descent
            for j=1:d
                curnode = node{j}(:,I(j),:);
                grad = gradnode{j}(:,I(j),:);
                curnode =  curnode -  grad - 1e-6 * curnode;
                node{j}(:,I(j),:) = curnode;                
            end
            
            
            if it==1
                fprintf('it:%d, err=%6f\n',it, sqrt(perr(1).^2));
            end
            
            if (mod(it,10000)==0 )
                fprintf('it:%d, err=%6f\n',it, sqrt(mean(perr.^2)));
              
%                 tr=tensor_ring;
%                 tr=cell2core(tr,node);
%                 rmse = [rmse,norm(c(:)-full(tr))/sqrt(numel(c))];
            end
            
            if it > max(prod(n)*10,1e6)
                disp('Reaching Maximum iteration!!!');
                break;
            end
            
        end
        
      %  figure; plot(rmse);
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    
    if strcmp(Alg,'BSGD')
        rng('default');
        lrate = 0.01;        % learning rate
        momentum = 0.1;      % forget rate
        batchsize = 10;     % batch sample size
        
        c=varargin{1};
        n=size(c);
        n=n(:);
        d=numel(n);
        
        
        node=cell(1,d);
        gradnode=cell(1,d);
        r=Rank(:);
        for i=1:d-1
            node{i}=randn(r(i),n(i),r(i+1));
            gradnode{i}=zeros(r(i),n(i),r(i+1));
        end
        node{d}=randn(r(d),n(d),r(1));
        gradnode{d}=zeros(r(d),n(d),r(1));
        
        for i=1:d
           node{i} = node{i}./max(abs(node{i}(:))); 
        end
        
        rmse = []; 
        perr = ones(1,1000); it=0;
        num=cell(1,d);  
        while  sqrt(mean(perr.^2)) > Tol
            it = it+1;
            oldgradnode = gradnode;
            
            for i=1:d
                num{i} = zeros(1,n(i));
                gradnode{i} = zeros(size(gradnode{i}));
            end
            
%             samSub = cell(1,d);
%             samVal = randsample(prod(n), batchsize);
%             [samSub{1:d}] = ind2sub(n', samVal);
%             samSub = cell2mat(samSub);

            for ns=1:batchsize
                % sample one tensor entry
                
                for j=1:d
                    I(j) = randsample(n(j),1);
                    num{j}(I(j)) = num{j}(I(j))+1;
                end
                % compute stochastic gradient
                for j=1:d
                    b = 1;
                    for k=[j+1:d,1:j-1]
                        b = squeeze(b) * squeeze(node{k}(:,I(k),:));
                    end
                    if j==1
                        chat = trace(squeeze(node{j}(:,I(j),:))*squeeze(b));
                        sidx = num2cell(I);
                        perr = circshift(perr,1);
                        perr(1) = chat - c(sidx{:});
                    end
                    gradnode{j}(:,I(j),:) = squeeze(gradnode{j}(:,I(j),:)) + b'* perr(1);
                end
            end
            
            for j=1:d
                 num{j}(num{j}==0) = 1;
                 gradnode{j} = gradnode{j} ./ repmat(num{j},[size(gradnode{j},1),1,size(gradnode{j},3)]);
                 gradnode{j} = momentum * oldgradnode{j} + lrate * gradnode{j};
            end
            
            % gradient descent
            for j=1:d
                node{j} = node{j} - gradnode{j} - 1e-9 * node{j};
            end
                      
            if (mod(it*batchsize,10000)==0)
                fprintf('It:%d, err=%6f\n', it, sqrt(mean(perr.^2)));
%                 tr=tensor_ring;
%                 tr=cell2core(tr,node);
%                 rmse = [rmse,norm(c(:)-full(tr))/sqrt(numel(c))];
            end
            
                   
            if it*batchsize > max(prod(n)*10,1e6) && it > 1000
                disp('Reaching Maximum iteration!!!');
                break;
            end
            
        end
        
%         figure; plot(rmse);
        t.node=node;
        t.d=d;
        t.n=n;
        t.r=r;
        return;
    end
    
    
end;








