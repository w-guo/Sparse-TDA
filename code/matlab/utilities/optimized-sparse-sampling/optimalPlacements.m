function [ loc ] = optimalPlacements( U, r_opt, p )

if (p>=r_opt)
    Ur = U(:,1:r_opt);
else
    Ur = U(:,1:p);
end

if (p==r_opt)
    [~,~,pivot] = qr(Ur.',0);
elseif (p>r_opt) 
    [~,~,pivot] = qr(Ur*Ur.',0);
else
    [~,~,pivot] = qr(Ur.','vector');
end

loc = pivot(1:p);

end