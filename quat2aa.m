function aa = quat2aa( Qraw )
    aa = nan(rows(Qraw),3);
    for i = 1:rows(Qraw)
        aa(i,:) = logquat( Qraw(i,4), Qraw(i,3), Qraw(i,2), Qraw(i,1) );
    end    
end    