function M = neighbors(X,n)
    M = buffer( X, n, n-1 )( :, n:end )';
end
