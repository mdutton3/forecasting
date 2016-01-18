irow = 209;
%testaapred
%t = testaapred(AAraw);
nx = neighbors( AAraw(:,1), histlen+1+predlen )( irow, : );
pred1=[ nan(1, columns(nx)-columns(t{1}.X.predfull)), t{1}.X.predfull(irow,:) ];
pred2=[ nan(1, columns(nx)-columns(t{2}.X.predfull)), t{2}.X.predfull(irow,:) ];
pred3=[ nan(1, columns(nx)-columns(t{3}.X.predfull)), t{3}.X.predfull(irow,:) ];
pred4=[ nan(1, columns(nx)-columns(t{4}.X.predfull)), t{4}.X.predfull(irow,:) ];
figure; plot( [nx; pred1; pred2; pred3; pred4]' );
legend( "act", "lag", "p1", "p2", "p3" );
