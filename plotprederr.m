% Why doesn't this have syntax highlighting?
1;

function S = predpoly( N, histlen, predlen, order )
    weights = sgmat(histlen,0,order);
    mFuture = fliplr( vander( 0:predlen, order + 1) ); % polynomial values at future times 0..predlen
    M = mFuture * weights; % Compute future Y given past Y
    S = struct();
    inow = columns(N)-predlen;
    S.X = N(:,inow-histlen:inow);
    S.Y = N(:,inow:end);
    S.pred = S.X * M';
    S.err = abs( S.pred - S.Y );
    S.name = sprintf( "Poly-%u(%u)", order, histlen );
    S.joined = [ N(:,1:inow-1) S.pred ];
end

t = cell(1,1);
idx = 0;

histlen = max( [ 2 8 15 22 ]' );
predlen = 4;
N = neighbors( x, histlen+1+predlen );

t{++idx} = predpoly( N, 2,  predlen, 1 ); 
t{++idx} = predpoly( N, 8,  predlen, 2 );
t{++idx} = predpoly( N, 15, predlen, 3 );
t{++idx} = predpoly( N, 22, predlen, 4 );

M = zeros( rows(N), numel(t), columns(N) );
l = cell(1,1);

M(:,1,:) = N;
l{1} = "data";
for i = 1:numel(t)
    M(:,i+1,:) = t{i}.joined;
    l{i+1}=sprintf("p%u", i);
end

function R = getrow(M,i)
    s=size(M);
    R = reshape(M(i,:,:),s(2),s(3))';
end

size( getrow(M,1009) )
plot( getrow(M,1009) ); legend(l);

