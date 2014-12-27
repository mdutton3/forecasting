function [S, M] = testlls( data, histlen, predlen )
    %printf("\testlls( % 5u, % 2u, % 2u )", numel(data), histlen, predlen );
    % Y=XM, solve for M
    N = neighbors( data, histlen+1+predlen );
    S.X = N(:,1:(1+histlen));
    %S.X(:,1:histlen) -= repmat( S.X(:,columns(S.X)), 1, histlen );
    %S.X(:,columns(S.X)) = 1;%ones(rows(S.X),1);
    S.Y = N(:,columns(N)-predlen:end);
    M=S.X\S.Y;
    S.pred = S.X * M;
    S.err = abs( S.pred - S.Y );
    S.name = sprintf( "LLS(%u)", histlen );
end
