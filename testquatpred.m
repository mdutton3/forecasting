% Why doesn't this have syntax highlighting?
function t= testquatpred( Qraw )

    function S = predpolyquat( Nx, Ny, Nz, Nw, histlen, predlen, order )
        nrows=rows(Nx);
        ncols=predlen+1;

        printf("predpolyquat( %u, %u, %u, %u )\n", nrows, histlen, predlen, order );

        weights = sgmat(histlen,0,order);
        mFuture = fliplr( vander( -histlen:predlen, order + 1) ); % polynomial values at future times 0..predlen
        M = mFuture * weights; % Compute future Y given past Y
        
        inow = columns(Nx)-predlen;

        % Unnormalized predictions
        px = Nx(:,inow-histlen:inow) * M';
        py = Ny(:,inow-histlen:inow) * M';
        pz = Nz(:,inow-histlen:inow) * M';
        pw = Nw(:,inow-histlen:inow) * M';
        
        % Normalize the predictions
        disp( "Normalizing predictions...");
        qnorm = sqrt( px.^2 + py.^2 + pz.^2 + pw.^2 );
        px = px ./ qnorm;
        py = py ./ qnorm;
        pz = pz ./ qnorm;
        pw = pw ./ qnorm;

        % Actuals, t=0..predlen
        ax = Nx(:,inow:end);
        ay = Ny(:,inow:end);
        az = Nz(:,inow:end);
        aw = Nw(:,inow:end);

        qnorm = sqrt( ax.^2 + ay.^2 + az.^2 + aw.^2 );
        ax = ax ./ qnorm;
        ay = ay ./ qnorm;
        az = az ./ qnorm;
        aw = aw ./ qnorm;
        
        disp("Computing errors...");
        %pred = cell(nrows,ncols);
        %actual = cell(nrows,ncols);
        abserr = nan(nrows,ncols);
        for icol = 1:ncols
            ang = arrayfun( @deltaquat, 
                          px(:,icol), py(:,icol), pz(:,icol), pw(:,icol),
                          ax(:,icol), ay(:,icol), az(:,icol), aw(:,icol) );
            abserr(:,icol) = ang;
        end
#            for irow = 1:nrows
#                pred{irow,icol} = quaternion( pw(irow,icol), px(irow,icol), py(irow,icol), pz(irow,icol) );
#                actual{irow,icol} = quaternion( aw(irow,icol), ax(irow,icol), ay(irow,icol), az(irow,icol) );
#                qdiff1=inv( pred{irow,icol} ) * actual{irow,icol};
#                qdiff2=inv( -pred{irow,icol} ) * actual{irow,icol};
#                %qdiff2=(-inv( actual{irow,icol} ) * pred{irow,icol};
#                abserr(irow,icol) = 2* min( arg( qdiff1 ), arg( qdiff2 ) );
#            end
#        end
        
        S=struct();
        %S.pred = pred;
        %S.actual = actual;
        S.err = abserr;
        S.name = sprintf( "PolyQ-%u(%u)", order, histlen );
    end

    t = cell(1,1);
    idx = 0;

    histlen = max( [ 2 8 15 ]' );
    predlen = 4;

    Nx = neighbors( Qraw(:,1), histlen+1+predlen );
    Ny = neighbors( Qraw(:,2), histlen+1+predlen );
    Nz = neighbors( Qraw(:,3), histlen+1+predlen );
    Nw = neighbors( Qraw(:,4), histlen+1+predlen );
    
    t{++idx} = predpolyquat( Nx, Ny, Nz, Nw,  2,  predlen, 1 );
    #t{++idx} = predpolyquat( Nx, Ny, Nz, Nw,  8,  predlen, 2 );
    %t{++idx} = predpolyquat( Nx, Ny, Nz, Nw, 15,  predlen, 3 );
    %t{++idx} = predpolyquat( Nx, Ny, Nz, Nw, 22,  predlen, 4 );

    plot( t{1}.err(:,end) );
end

