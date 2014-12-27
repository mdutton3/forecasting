function S = testpoly( data, histlen, predlen, order )
    %printf("\nTestPoly( % 5u, % 2u, % 2u, % 2u )", numel(data), histlen, predlen, order );
    weights = sgmat(histlen,0,order);
    mFuture = fliplr( vander( 0:predlen, order + 1) ); % polynomial values at future times 0..predlen
    m = mFuture * weights; % Compute future Y given past Y
    N = neighbors( data, histlen+1+predlen );
    S = struct();
    S.X = N(:,1:columns(m));
    S.Y = N(:,columns(N)-predlen:end);
    S.pred = S.X * m';
    S.err = abs( S.pred - S.Y );
    S.name = sprintf( "Poly-%u(%u)", order, histlen );
end

