% Axis-Angle forecasting
%function t= testaapred( AAraw )
1;

    function [s,v] = aa2q( aa )
        len = norm(aa,2,"rows");
        half_theta = len ./ 2;
        s = cos(half_theta);
        v = aa .* repmat(sin(half_theta) ./ len, 1, 3);
    end

    function [qs,qv] = qmult( s1, v1, s2, v2 )
        qs = s1.*s2 - dot(v1,v2,2);
        qv = repmat(s1,1,3).*v2 + repmat(s2,1,3).*v1 + cross(v1,v2,2);
    end

    function rad = aa_angle( aa1, aa2 )
        [s1,v1] = aa2q(aa1);
        [s2,v2] = aa2q(aa2);
        [qs, qv] = qmult( s1, v1, s2, v2 );
        rad = 2 * atan2( norm(qv,2,"rows"), qs );
    end

    function S = predpolyvec_w( Nx, Ny, Nz, histlen, predlen, order, weights )
        nrows=rows(Nx);
        ncols=predlen+1;
        
        fprintf(stderr, "predpolyvec( %u, %u, %u, %u )\n", nrows, histlen, predlen, order );        

        mFuture = fliplr( vander( -histlen:predlen, order + 1) ); % polynomial values at future times 0..predlen
        M = mFuture * weights; % Compute future Y given past Y
        
        inow = columns(Nx)-predlen;

        X = Nx(:,inow-histlen:inow);
        Y = Ny(:,inow-histlen:inow);
        Z = Nz(:,inow-histlen:inow);
        
        % Unnormalized predictions
        pxfull = X * M'; px = pxfull(:,end-predlen:end);
        pyfull = Y * M'; py = pyfull(:,end-predlen:end);
        pzfull = Z * M'; pz = pzfull(:,end-predlen:end);

        % Actuals, t=0..predlen
        ax = Nx(:,inow:end);
        ay = Ny(:,inow:end);
        az = Nz(:,inow:end);
        
        S=struct();
        S.X = struct();
        S.X.in = X;
        S.X.pred = px;
        S.X.predfull = pxfull;
        S.X.actual = ax;
        S.X.err = px - ax;
        
        %S.Y = struct();
        %S.Y.in = Y;
        %S.Y.pred = py;
        %S.Y.actual = ay;
        %S.Y.err = py - ay;
        
        %S.Z = struct();
        %S.Z.in = Z;
        %S.Z.pred = pz;
        %S.Z.actual = az;
        %S.Z.err = pz - az;

        fprintf(stderr,"Computing errors...\n");
        %err = sqrt( (px-ax).^2 + (py-ay).^2 + (pz-az).^2 );
        %S.err = err;
        temp = aa_angle( -[px(:), py(:), pz(:)], [ax(:) ay(:) az(:)] ) * (180 / pi);
        S.deg = reshape( temp, rows(px), columns(px) );
        S.name = sprintf( "PolyAA-%u(%u)", order, histlen );
    end
    
    function S = predpolyvec( Nx, Ny, Nz, histlen, predlen, order )
        weights = sgmat(histlen,0,order);
        S = predpolyvec_w( Nx, Ny, Nz, histlen, predlen, order, weights );
    end
    
    function S = predpolyvec2( Nx, Ny, Nz, histlen, predlen, order, histlen2, order2 )
        weights = sgmat(histlen,0,order);
        weights2 = sgmat(histlen2,0,order2);
        blend = zeros( max( [size(weights); size(weights2)] ) );
        blend( 1:rows(weights), end-columns(weights)+1:end ) += weights;
        blend( 1:rows(weights2), end-columns(weights2)+1:end ) += weights2;
        blend /= 2;
        blend
        S = predpolyvec_w( Nx, Ny, Nz, max(histlen,histlen2), predlen, max(order,order2), blend );
        S.name = sprintf( "blend-%u-%u(%u,%u)", order, order2, histlen, histlen2 );
    end

    function S = lagvec( Nx, Ny, Nz, histlen, predlen )
        nrows=rows(Nx);
        ncols=predlen+1;
        
        fprintf(stderr, "lagvec( %u, %u, %u )\n", nrows, histlen, predlen );        

        inow = columns(Nx)-predlen;

        X = Nx(:,inow-histlen:inow);
        Y = Ny(:,inow-histlen:inow);
        Z = Nz(:,inow-histlen:inow);
        
        % Unnormalized predictions
        px = pxfull = repmat( X(:,end), 1, predlen+1 );
        py = pyfull = repmat( Y(:,end), 1, predlen+1 );
        pz = pzfull = repmat( Z(:,end), 1, predlen+1 );

        % Actuals, t=0..predlen
        ax = Nx(:,inow:end);
        ay = Ny(:,inow:end);
        az = Nz(:,inow:end);
        
        S=struct();
        S.X = struct();
        S.X.in = X;
        S.X.pred = px;
        S.X.predfull = pxfull;
        S.X.actual = ax;
        S.X.err = px - ax;
        
        %S.Y = struct();
        %S.Y.in = Y;
        %S.Y.pred = py;
        %S.Y.actual = ay;
        %S.Y.err = py - ay;
        
        %S.Z = struct();
        %S.Z.in = Z;
        %S.Z.pred = pz;
        %S.Z.actual = az;
        %S.Z.err = pz - az;

        fprintf(stderr,"Computing errors...\n");
        %S.err = sqrt( (px-ax).^2 + (py-ay).^2 + (pz-az).^2 );
        temp = aa_angle( -[px(:), py(:), pz(:)], [ax(:) ay(:) az(:)] ) * (180 / pi);
        S.deg = reshape( temp, rows(px), columns(px) );
        S.name = sprintf( "Lag-%u(%u)", 0, histlen );
    end

    t = cell(1,1);
    idx = 0;

    histlen = max( [ 8 32 60 86 ]' );
    predlen = ceil(33/3);

    Nx = neighbors( AAraw(:,1), histlen+1+predlen );
    Ny = neighbors( AAraw(:,2), histlen+1+predlen );
    Nz = neighbors( AAraw(:,3), histlen+1+predlen );
    
    %figure; plot( Nx(:,end-predlen) ); title( "x of log(q)");

    t{++idx} = lagvec( Nx, Ny, Nz, 8, predlen );
    t{++idx} = predpolyvec( Nx, Ny, Nz, 12,  predlen, 1 );
    t{++idx} = predpolyvec( Nx, Ny, Nz, 16,  predlen, 2 );
%    t{++idx} = predpolyvec( Nx, Ny, Nz,  8,  predlen, 1 );
%    t{++idx} = predpolyvec( Nx, Ny, Nz, 12,  predlen, 2 );
%    t{++idx} = predpolyvec( Nx, Ny, Nz, 42,  predlen, 3 );
%    t{++idx} = predpolyvec( Nx, Ny, Nz,  86,  predlen, 4 );

    t{++idx} = predpolyvec2( Nx, Ny, Nz,  12,  predlen, 1, 12, 2 );
    
    stemp = nan( rows(t{1}.deg(100:end-100,end)(1:3:end,:)), numel(t) );
    lbl = cell(1,1);
    for i = 1:numel(t)
        stemp(:,i) = sort( t{i}.deg(100:end-100,end-predlen+1) )(1:3:end,:);
        lbl{i} = sprintf( "%s: %f", t{i}.name, mean( stemp(:,i) ) );
        %figure(i); title(t{i}.name); plot( sort(temp), linspace(0,1,rows(temp)) ); %legend("0","1", "2","3","4");
    end
    figure; plot( stemp, linspace(0,1,rows(stemp)) ); legend( lbl );
%end

