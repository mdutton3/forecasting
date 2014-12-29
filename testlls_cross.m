function S = testlls_cross( xtrain, xtest, seglen, histlen, predlen )
    assert( size(xtrain) == size(xtest) );

    %printf("\testlls_cross( % 5u, % 2u, % 2u )", numel(data), histlen, predlen );
    % Cross validate testlls
    Ntrain = neighbors( xtrain, histlen+1+predlen );
    Ntest = neighbors( xtest, histlen+1+predlen );
%    size(Ntrain), size(Ntest)

    t = cell(0,0);
    n = floor( rows(Ntrain)/seglen ); %Floor here to truncate partial segments
    segidx = ceil((1:rows(Ntrain)) / seglen);
    for i = 1:n
        train = Ntrain(segidx != i,:);
        test = Ntest(segidx == i,:);

        %i
        %disp("set sizes:");
        %size(Ntrain), size(train), size(test)

        [S, M] = testlls_n( train, histlen, predlen );
        S = testlls_n( test, histlen, predlen ); % Not actually running this, just using it for data setup
        S.pred = S.X * M; %Reprocess with the M from the training set
        S.err = abs( S.pred - S.Y );
        t{i} = S;
%        size(S.X)
    end
    
    S = t{1};
    for i = 2:n
%        printf( "Seg %u = %u\n", i, rows(t{i}.X) );
        S.X = [ S.X; t{i}.X ];
        S.Y = [ S.Y; t{i}.Y ];
        S.pred = [ S.pred; t{i}.pred ];
        S.err = [ S.err; t{i}.err ];
    end
    S.name = sprintf("LLS-xv(%u,%u)", histlen,seglen);
end
