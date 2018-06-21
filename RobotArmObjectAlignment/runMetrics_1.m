clear
clc
% Run metrics
dir = '/home/reu3/NearContactStudy/InterpolateGrasps/';
fn = 'Test_bHand3';
strMesh = strcat(dir, fn, '.STL');
mO = stlread(strMesh); %generate two structs: faces and vertices

% Create handrep goes here
handrep = struct;

% Define hand features that face the object, will add more later
strConv = { 'palm', 'finger1_inner', 'finger1_outer', 'finger2_inner', 'finger2_outer'};
handrep.names = strConv;
handrep.vIds = zeros( length( strConv ), 3 );
handrep.vBarys = zeros( length( strConv ), 3 );
handrep.vNorms = zeros( length( strConv ), 3 );

% Calculate points and barycentric coordinates
%see whether there's difference using ply or stl 
for k = 1:size( strConv, 2)
    clf
    strBase = strcat(dir, name, '_', strConv{k}); % textfiles that store 3D points for each hand feature, generated by Manifold Mesh Processing
    [m, ids, barys, norms] = PointsToBary( strMesh, strcat(strBase, '.txt'), strBase);
    handrep.vIds(k,:) = ids(1,:) + 18; % Account for wacky v number (ASK!!)
    handrep.vBarys(k,:) = barys(1,:);
    handrep.vNorms(k,:) = norms(1,:);    
end

pts = zeros(size(handrep.vIds, 1), 3);
norms = pts;
for k = 1:size( strConv, 2 )
    [pt, norm] = Reconstruct(m, handrep.vIds(k,:) - 18, handrep.vBarys(k,:) );
    % pts = [pt pt+norm * 0.1];
    pts(k,:) = pt;
    norms(k,:) = norm;
end