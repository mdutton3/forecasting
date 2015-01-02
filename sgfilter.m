function [ xhat, xrange, filtererr ] = sgfilter(data, nleft, nright, order)
    weights = sgmat(nleft,nright,order)(1,:); % Grab the weights for the t^0 coefficient
    xhat = neighbors( data, columns(weights) ) * weights'; % Apply filter, cuts off both ends
    xrange = nleft+1:numel(data)-nright; % The corresponding range in the original data, after cutting off ends
    filtererr = xhat - data(xrange);
    %disp("Filter stats:"), [ numel(data) numel(xhat) sumsq(filtererr) mean(filtererr) var(filtererr) ]
end

