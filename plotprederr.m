% Why doesn't this have syntax highlighting?
1;

function S = predpoly( N, histlen, predlen, order )
    weights = sgmat(histlen,0,order);
    mFuture = fliplr( vander( -histlen:predlen, order + 1) ); % polynomial values at future times 0..predlen
    M = mFuture * weights; % Compute future Y given past Y
    S = struct();
    inow = columns(N)-predlen;
    S.X = N(:,inow-histlen:inow);
    S.pred = S.X * M';
    S.fit = meansq( (S.pred(:,1:1+histlen) - N(:,inow-histlen:inow))' )'; % The MSE of the poly-fit at each row
    S.Y = N(:,inow:end);    
    S.err = ( S.pred(:,columns(S.pred)-predlen:end) - S.Y );
    S.name = sprintf( "Poly-%u(%u)", order, histlen );
    S.joined = [ nan(rows(N), columns(N)-columns(S.pred)) S.pred ];
end

t = cell(1,1);
idx = 0;

histlen = max( [ 2 8 15 ]' );
predlen = 4;
N = neighbors( x, histlen+1+predlen );

t{++idx} = predpoly( N, 2,  predlen, 1 ); 
t{++idx} = predpoly( N, 8,  predlen, 2 );
t{++idx} = predpoly( N, 15, predlen, 3 );
%t{++idx} = predpoly( N, 22, predlen, 4 );

S = t{1};
S.err = (t{1}.err + t{2}.err) ./ 2;
S.joined = (t{1}.joined + t{2}.joined) ./ 2;
S.name = "blend";
t{++idx} = S;

M = nan( rows(N), numel(t)+1, columns(N) );
fitmse = nan( rows(N), numel(t)+1 );
l = cell(1,1);

M(:,1,:) = N;
fitmse(:,1) = 0;
l{1} = "data";
for i = 1:numel(t)
    M(:,i+1,:) = t{i}.joined;
    fitmse(:,i+1) = t{i}.fit;
    l{i+1}=t{i}.name;
end

function R = getrow(M,i)
    s=size(M);
    R = reshape(M(i,:,:),s(2),s(3))';
end

e1 = t{1}.err(:,5); e2 = t{2}.err(:,5); ea = t{end}.err(:,5);
err = [ e1 e2 ea ];
[vmax,imax]=max( abs(ea)-abs(e1) )
[vmin,imin]=min( abs(ea)-abs(e1) )

size( M )

function plotrow( M, fitmse, l, i )
    r=getrow(M,i);
    plot( 1:rows(r), r, "-@" ); legend(l); title(sprintf("Pred at row %u", i));
    %figure;
    %bar( fitmse(i,:) ); title(sprintf("MSE of poly fit at row %u", i));
end

%figure; plotrow( M, fitmse, l, imin );
%figure; plotrow( M, fitmse, l, imax );

