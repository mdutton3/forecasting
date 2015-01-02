% A script
1;

function R = colright( M, n )
    R = M(:,end-n+1:end);
end

function [tvar, leg] = calcLagVar( N, t, predlen )
    ncol=predlen+1;

    N_future = colright(N,ncol);
    ynow = repmat(N_future(:,1),1,ncol);

    tvar=nan( numel(t)+1, ncol );
    leg=cell( numel(t)+1, 1 );

    idx=1;
    tvar(idx,:) = var( N_future - ynow ); % Variance due to lag
    leg(idx) = "Lag";
    for i = 1:numel(t)
        pred = colright( t{i}.joined,ncol );
        tvar(idx+i,:) = var( pred - ynow ); % Variance due to (lag - prediction)
        leg(idx) = t{i}.name;
    end
end

[tvar, tvar_leg] = calcLagVar( N, t, predlen );
[tvar_hat, tvar_hat_leg] = calcLagVar( Nhat, t, predlen );

