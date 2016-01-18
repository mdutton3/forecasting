function aa = quat2aa_2( Qraw )
    len = norm( Qraw, 2, "rows" ); % Unit length
    xyz = Qraw(:,1:3) ./ repmat(len,1,3);
    w = Qraw(:,4) ./ len;

    axislen = norm( xyz, 2, "rows" );
    angle = 2 * atan2( axislen, w );
    axis = xyz ./ repmat(axislen,1,3);

    aa = axis .* repmat(angle, 1, 3);
end    