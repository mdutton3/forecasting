%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This produces a Savitsky-Golay convultion matrix such that the coefficients
% of the fit polynomial are (e.g.):
% trans([x v a]) = sgmat(nl,nr,2) * trans( [y_{-nl} ... y_0 ... y_{nr}] )
function ret = sgmat( nl, nr, order )
    %printf( "sgmat( %u, %u, %u ):\n", nl, nr, order );
    A = fliplr( vander(-nl:nr, order+1) );
    ret = inv( A'*A ) * A';
end
