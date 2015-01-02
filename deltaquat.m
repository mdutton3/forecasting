function ang = deltaquat( x1, y1, z1, w1, x2, y2, z2, w2 )
    q1 = quaternion( w1, x1, y1, z1 );
    q2 = quaternion( w2, x2, y2, z2 );
    qdiff1 = inv(  q1 ) * q2;
    qdiff2 = inv( -q1 ) * q2;
    ang = 2* min( arg( qdiff1 ), arg( qdiff2 ) );
end
