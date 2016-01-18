function angvec = logquat( w, x, y, z )
    %len = norm( [w, x, y, z], 2 );
    %theta = atan2( norm([x y z],2)/len, w/len );
    q = unit( quaternion( w, x, y, z ) );
    [axis, angle] = q2rot( q );
    angvec = axis * angle / norm(axis);
end    