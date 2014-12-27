%clear
%loaddata
1; %Mark this as a script

clear S;
clear t;

idx = 1;

for i = 4:4:100
    t{idx++} = testpoly( x, i,  4, 2 );
end

%t{idx++} = testpoly( x, 12,  4, 1 );
%t{idx++} = testpoly( x, 12,  4, 3 );
%t{idx++} = testpoly( x, 12,  4, 4 );
%t{idx++} = testpoly( x, 20,  4, 4 );

%t{idx++} = testpoly( x, 4,  4, 2 );
%t{idx++} = testpoly( x, 12,  4, 2 );
%t{idx++} = testpoly( x, 20,  4, 3 );

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

serr = sort(err);
serridx = repmat( linspace(0,1,rows(serr))', 1, columns(serr));

plot( serr, serridx ); legend(l); grid("on");


