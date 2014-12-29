function [S, M] = testlls( data, histlen, predlen )
    %printf("\testlls( % 5u, % 2u, % 2u )", numel(data), histlen, predlen );
    % Y=XM, solve for M
    N = neighbors( data, histlen+1+predlen );
    [S M] = testlls_n( N, histlen, predlen );
end
