% @arg data The raw data
% @arg a The coeffecients of the AR model (e.g. from arburg)
function S = arpred( data, a, predlen )
    M = arpow( a, predlen );
    % Column 1 was t_(n-1) but neighbors(...) puts the latest in the last col
    M = fliplr( M );
    
    N = neighbors( data, columns(a) + predlen );
    S.X = N(:,1:columns(a));
    S.Y = N(:,columns(a)+1:end);
    S.pred = S.X * M';
    S.err = S.pred - S.Y;
end
