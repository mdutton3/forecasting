load data mi mt si st
[ size(mi) size(mt) size(si) size(st) ]
xraw = mt(:,5);
%xraw = mt(:,6);
%xraw = mt(:,7);

[ xhat, xrange, err ] = sgfilter(xraw, 5, 5, 2);
x = xraw(xrange);

