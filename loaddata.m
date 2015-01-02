% Loads test data and provides utility functions
1;

pkg load all

% ==> raw/still_imu.csv <==
% qx, qy, qz, qw, linA_x, linA_y, linA_z, corA_x, corA_y, corA_z, ts, qpc
% ==> raw/still_track.csv <==
% qx, qy, qz, qw, px, py, pz, track, lag, adjusted, lastIMU, qpc

function q = getquat( M, i )
    q = quaternion( M(i,4), M(i,1), M(i,2), M(i,3) );
end

function qpc = getqpc( M, i )
    qpc = M(i,end);
end

function idx = lookup_qpc( M, qpc )
    idx = lookup( M(:,12), qpc );
end

function ts = get_trackts( M, i )
    ts = M(i,8);
end

load data mi mt si st
%[ size(mi) size(mt) size(si) size(st) ]

% Append IMU index to track tables
mt(:,end+1) = lookup_qpc( mi, mt(:,12) );
st(:,end+1) = lookup_qpc( si, st(:,12) );

[ size(mi) size(mt) size(si) size(st) ]

qpf =  2.73057667411303; % QPC ticks per microsecond

xraw = mt(:,5);
%xraw = mt(:,6);
%xraw = mt(:,7);

[ xhat, xrange, err ] = sgfilter(xraw, 5, 5, 2);
x = xraw(xrange);

