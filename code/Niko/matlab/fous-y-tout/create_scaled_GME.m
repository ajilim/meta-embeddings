function E = create_scaled_GME(B,a,beta,logscale)
% Creates an object representing a multivariate Gaussian meta-embedding.
% The Gaussian is represented by its natural parameters, a in R^d 
% and beta*B, a positve semi-definite matrix, where beta>0 is scalar. The 
% meta-embedding is: 
%
%   f(z) = exp(a'z -(beta/2)z'Bz + logscale)
%
% The `object' created here is home-made in the sense that it does not use
% MATLAB's object-oriented mechanisms. Rather it is a struct, containing
% several function handles, all of which have access to a common set of 
% persistent, encapsulated local variables (here just a,B).
%
% Inputs: 
%   B: scaled_GME_precision. B must be common to all scaled
%                            meta-embeddings.
%   a: natural parameter: a = beta*B*mu
%   beta: precision scaling factor
%   logscale: scalar



    E.log_expectation = @log_expectation;
    E.pool = @pool;
    E.getNatParams = @getNatParams;
    E.get_mu_cov = @get_mu_cov;
    E.shiftlogscale = @shiftlogscale;
    E.raise = @raise;
    E.convolve = @convolve;
    
    E = equip_ME(E);
 
    if ~exist('logscale','var')
        logscale = 0;
    end
    
    
    
    
    % returns the same a,B used in construction
    function [a1,beta1,logscale1] = getNatParams()
        a1 = a;
        beta1 = beta;
        logscale1 = logscale;
    end

    % Returns new object, constructed with sum of natural parameters of 
    % this Gaussian and another represented by AE. This is just the product 
    % of the two Gaussians.
    function PE = pool(AE)
        [a1,beta1,s1] = AE.getNatParams();
        PE = create_plain_GME(B,a+a1,beta+beta1,logscale+s1);
    end

    % Raises meta-embedding to the power s.
    % It scales the natural parameters.
    function PE = raise(e)
        PE = create_plain_GME(B,e*a,e*beta,e*logscale);
    end


    function PE = shiftlogscale(shift)
        PE = create_plain_GME(B,a,beta,logscale+shift);
    end

% Computes log E{f(z)}, w.r.t. N(0,I)
    function y = log_expectation()
        %cholBI = chol(speye(dim) + B);
        %logdetBI = 2*sum(log(diag(cholBI)));
        %mu = cholBI\(cholBI'\a);
        logdetBI = B.logdet(beta);
        mu = B.solve(a,beta);
        y = (mu'*a - logdetBI)/2;
    end



    %For inspection purposes (eg plotting), not speed
    % Returns mu = B\a and C = inv(B)
    function [mu,C] = get_mu_cov()
        mu = (beta*B)\a;
        C = inv(beta*B);
    end
    

 
    


end