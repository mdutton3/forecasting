%clear
%loaddata
1; %Mark this as a script

clear S;
clear t;

idx = 1;

sserr = nan(3,1);
tvar = nan(3,1);
for i = 3:3
    S = testlls_cross( x, x, 10, i, 4 );
    %t{idx++} = S;
    sserr(i,1) = sumsq( S.err(:,end) );
    tvar(i,1) = var( S.err(:,end) );
    i, sserr(i,1), tvar(i,1)
end

figure(1);
%plot( sserr );

figure(2);
%plot( tvar );

%% Best of class
t{idx++} = testpoly( x, 2,  4, 1 );
t{idx++} = testpoly( x, 8,  4, 2 );
t{idx++} = testpoly( x, 15,  4, 3 );
t{idx++} = testpoly( x, 22,  4, 4 );
t{idx++} = testlls( xhat, 12,  4 ); % Higher histlen values are better
t{idx++} = testlls( x, 16,  4 ); % Higher histlen values are better
t{idx++} = testlls_cross( xhat, x, 11, i, 4 );
t{idx++} = testlls_cross( x, x, 10, i, 4 );

%% Previous tests
%t{idx++} = testlls( xhat, 12, 4 );
%t{idx++} = testlls_cross( xhat, x, 50, 12, 4 );
%t{idx++} = testlls_cross( xhat, x, 100, 12, 4 );
%t{idx++} = testlls_cross( x, x, 99, 12, 4 );
%t{idx++} = testlls_cross( xhat, x, 500, 12, 4 );
%t{idx++} = testlls_cross( xhat, x, 1000, 12, 4 );

minrows = 99999;
maxrows = 0;
for i = 1:columns(t)
    minrows = min( [ minrows; rows( t{i}.X ) ] );
    maxrows = max( [ maxrows; rows( t{i}.X ) ] );
end
minrows, maxrows

err = zeros(minrows,columns(t));
l=cell(1,columns(t));
for i = 1:columns(t)
    offset = rows(t{i}.X) - minrows + 1;
    t{i}.X    = t{i}.X( offset:end, : );
    t{i}.Y    = t{i}.Y( offset:end, : );
    t{i}.pred = t{i}.pred( offset:end, : );
    t{i}.err  = t{i}.err( offset:end, : );
    
    terr = abs( t{i}.err(:,5) );
    err(:,i) = terr;
    l(i) = sprintf( "%s=%f", t{i}.name, sumsq(terr) );
end

sumsq( err );

function plotserr( err, legnames )
    serr = sort(err);
    serridx = repmat( linspace(0,1,rows(serr))', 1, columns(serr));

    figure(10);
    plot( serr, serridx ); legend(legnames); grid("on");
    title( "Error CDF" );

    figure(11);
    [NN,XX] = hist(serr,50,1); plot( XX, NN ); legend(legnames); grid("on");
    title( "Error Histogram" );
end

if( columns(err) < 30 )
    plotserr( err, l )
end

