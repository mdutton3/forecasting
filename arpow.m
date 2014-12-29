% Use the 'a' vector of an auto-regressive model (e.g. from arburg)
% that predicts t_n from t_(n-1)...t_(n-p-1) and make a matrix (M)
% that predicts t_(n+len-1:n)
function M = arpow( a, len )
    n = columns(a)+len-1;
    A = [        a, zeros(1,len-1);
          eye(n-1), zeros(n-1,1) ];
    M = (A^len)(1:len,1:columns(a));
    M = flipud( M ); % first row becomes t_n, then t_(n+1)...
end
