function S = testlls_cross( data, datatest, seglen, histlen, predlen )
    %printf("\testlls_cross( % 5u, % 2u, % 2u )", numel(data), histlen, predlen );
    % Cross validate testlls
    t = cell(0,0);
    n = ceil( rows(data)/seglen );
    segidx = ceil((1:rows(data)) / seglen);
    for i = 1:n
        train = data(segidx != i);
        test = datatest(segidx == i);
%        size(data), size(train), size(test)
        [S, M] = testlls( train, histlen, predlen );
        S = testlls( test, histlen, predlen ); % Not actually running this, just using it for data setup
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
