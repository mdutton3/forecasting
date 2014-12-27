%Ac=y
%c=inv(A'*A)*A'*y
%c=ret*y
function ret = sgmat( nl, nr, order )
    A = fliplr( vander(-nl:nr, order+1) );
    ret = inv( A'*A ) * A';
end
