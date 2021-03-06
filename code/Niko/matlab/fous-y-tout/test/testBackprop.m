function total = testBackprop(block,X,mask)

    if ~iscell(X)
        X = {X};
    end


    dX = cellrndn(X); 
    if exist('mask','var')
       assert(length(mask)==length(X));
       dX = cellmask(dX,mask);
    end
    
    cX = cellcomplex(X,dX);
    DX = cell(size(X)); 
    
    
    [Y,back] = block(X{:});
    
    
    DY = randn(size(Y));
    [DX{:}] = back(DY);                  %DX = J'*DY
    

    dot1 = celldot(DX,dX);               %dX' * J' * DY
    
    
    cY = block(cX{:});
    [Y2,dY2] = recover(cY);              %dY2 = J*dX
    dot2 = DY(:).'*dY2(:);               %DY' * J* DX
    
    
    Y_diff = max(abs(Y(:)-Y2(:))),
    jacobian_diff = abs(dot1-dot2),
    

    
    total = Y_diff + jacobian_diff;
    if total < 1e-6
        fprintf('\ntotal error=%g\n',total);
    else
        fprintf(2,'\ntotal error=%g\n',total);
    end
    

end


function R = cellrndn(X)
    if ~iscell(X)
        R = randn(size(X));
    else
        R = cell(size(X));
        for i=1:numel(X)
            R{i} = cellrndn(X{i});
        end
    end
end


function X = cellmask(X,mask)
    if ~iscell(X)
        assert(length(mask)==1);
        X = X*mask;
    else
        for i=1:numel(X)
            X{i} = cellmask(X{i},mask{i});
        end
    end
end


function C = cellcomplex(X,dX)
    assert(all(size(X)==size(dX)));
    if ~iscell(X)
        C = complex(X,1e-20*dX);
    else
        C = cell(size(X));
        for i=1:numel(X)
            C{i} = cellcomplex(X{i},dX{i});
        end
    end
end

function [R,D] = recover(cX)
    if ~iscell(cX)
        R = real(cX);
        D = 1e20*imag(cX);
    else        
        R = cell(size(cX));
        D = cell(size(cX));
        for i=1:numel(cX)
            [R{i},D{i}] = recover(cX{i}); 
        end
    end
end


function dot = celldot(X,Y)
    assert(all(size(X)==size(Y)));
    if ~iscell(X)
        dot = X(:).' * Y(:);
    else
        dot = 0;
        for i=1:numel(X)
            dot = dot + celldot(X{i},Y{i});
        end
    end
end


