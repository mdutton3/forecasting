function results = xvalid( train, test, histlen, predlen, seglen )
    ncol = histlen + 1 + predlen;
    Ntrain = neighbors( train, ncol )';
    Atrain = Ntrain(:,1:(1+histlen));
    Btrain = Ntrain(:,(histlen+2):ncol);

    Ntest = neighbors( test, ncol )';
    Atest = Ntest(:,1:(1+histlen));
    Btest = Ntest(:,(histlen+2):ncol);

    nrow = rows(Ntrain);
    len=seglen;
    maxseg = ceil(nrow/len);
    results = nan( len, maxseg );
    for i = 1:maxseg
        mask = ( ceil( (1:nrow) / len ) == i );
        X = Atrain(!mask,:)\Btrain(!mask,:);
        err = Btest(mask,:) - Atest(mask,:)*X;
        err = abs(err);
        results(1:rows(err),i) = err(:,predlen);
    end
end

