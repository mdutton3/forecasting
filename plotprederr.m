% Why doesn't this have syntax highlighting?
1;

function S = predpoly_w( N, histlen, predlen, order, weights, label )
    mFuture = fliplr( vander( -histlen:predlen, order + 1) ); % polynomial values at future times 0..predlen
    M = mFuture * weights; % Compute future Y given past Y
    S = struct();
    inow = columns(N)-predlen;
    S.X = N(:,inow-histlen:inow);
    S.pred = S.X * M';
    S.fit = meansq( (S.pred(:,1:1+histlen) - N(:,inow-histlen:inow))' )'; % The MSE of the poly-fit at each row
    S.Y = N(:,inow:end);    
    S.err = ( S.pred(:,columns(S.pred)-predlen:end) - S.Y );
    S.name = label;
    S.joined = [ nan(rows(N), columns(N)-columns(S.pred)) S.pred ];
end

function S = predpoly( N, histlen, predlen, order )
    printf( "predpoly( %u, %u, %u ):\n", histlen, predlen, order );
    weights = sgmat(histlen,0,order);
    name = sprintf( "Poly-%u(%u)", order, histlen );
    S = predpoly_w( N, histlen, predlen, order, weights, label );
end

t = cell(1,1);
idx = 0;

histlen = max( [ 2 8 15 ]' );
predlen = 4;
N = neighbors( x, histlen+1+predlen );
Nhat = neighbors( xhat, histlen+1+predlen );

%t{++idx} = predpoly( N, 2,  predlen, 1 ); 
%t{++idx} = predpoly( N, 8,  predlen, 2 );
%t{++idx} = predpoly( N, 15, predlen, 3 );
%t{++idx} = predpoly( N, 22, predlen, 4 );

% Blend a linear and quadratic model
function W = sgblend( sg1, sg2, alpha )
    sz = max( [size(sg1); size(sg2)] );
    W = zeros( sz );
    W(1:rows(sg1),end+1-columns(sg1):end) += alpha .* sg1;
    W(1:rows(sg2),end+1-columns(sg2):end) += (1-alpha) .* sg2;
end

for alpha = [1, 0.5, 0.0];
    blend_weights = sgblend(sgmat(2,0,1), sgmat(8,0,2), alpha);
    label = sprintf( "Blend(%0.2f)", alpha );
    t{++idx} = predpoly_w( N, 8, predlen, 2, blend_weights, label );
end

if(0)
    S = t{1};
    S.err = (t{1}.err + t{2}.err) ./ 2;
    S.joined = (t{1}.joined + t{2}.joined) ./ 2;
    S.name = "blend";
    t{++idx} = S;
end

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

stats = nan(1+numel(t), columns(t{1}.err)*4);
lag= (N(:,end-predlen:end) - N(:,end-predlen)); % Error from lagging the last value
stats(1,:) = [ abs(mean(lag)), mean(abs(lag)), var(lag), var(abs(lag)) ];
%lag1= lag(:,2); % Error from lag at t=1
%stats(1,:) = repelems( [ abs(mean(lag1)), mean(abs(lag1)), var(lag1), var(abs(lag1)) ], [ 1, 2, 3, 4; 5, 5, 5, 5 ] )';
for i = 1:numel(t);
    stats(i+1,:) = [ abs(mean(t{i}.err)), mean(abs(t{i}.err)), var(t{i}.err), var(abs(t{i}.err)) ];
end

dstats = stats - min(stats);
figure(1); plot( stats(:,1:5)' ); title("Delta Abs-Mean-error"); legend(l{1:end});
figure(2); plot( stats(:,6:10)' ); title("Delta Mean-abs-error"); legend(l{1:end});
figure(3); plot( stats(:,11:15)' ); title("Delta Var-error"); legend(l{1:end});
figure(4); plot( stats(:,16:20)' ); title("Delta Var-abs-err"); legend(l{1:end});

