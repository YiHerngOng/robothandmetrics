% Run conversion scripts
addpath('STLRead');
global dSquareWidth;
global checkerboardSize;
dir = '/home/reu3/NearContactStudy/InterpolateGrasps/pregrasp_pose_data/';
name = 'Test_bHand3';

%Construct Table
dSquareWidth = 0.1;
checkerboardSize = [8,8];
v1 = [0.5,0.5,0];
v2 = [0.5,0,0];
v3 = [0,0,0];
v4 = [0,0.5,0]; 
ver = [v1,v2,v3,v4];

figure

%Construct Hand and its vectors
handrep = struct;
% strConv = { 'palm', 'finger1_inner', 'finger1_outer', 'finger2_inner', 'finger2_outer'};
strConv = { 'palm', 'palm_left', 'palm_right', ...
            'thumb_inner', ...
            'thumb_outer1', 'thumb_outer2',  'thumb_outer3', ...
            'finger1_inner', ...
            'finger1_outer1', 'finger1_outer2', 'finger1_outer3', ...
            'finger2_inner', ...
            'finger2_outer1', 'finger2_outer2', 'finger2_outer3'};
handrep.names = strConv;
handrep.vIds = zeros( length( strConv ), 3 );
handrep.vBarys = zeros( length( strConv ), 3 );
handrep.vNorms = zeros( length( strConv ), 3 );

strMesh = strcat(dir, name, '.STL');
clf
for k = 1:size(strConv,2)
    strBase = strcat(dir, strConv{k});
    [m, ids, barys, norms] = PointsToBary( strMesh, strcat(strBase, '.txt'), strBase);
    handrep.vIds(k,:) = ids(1,:) + 18; % Account for wacky v number
    handrep.vBarys(k,:) = barys(1,:);
    handrep.vNorms(k,:) = norms(1,:); 
end

%Draw table,hand and object
DrawTable(ver,true)
RenderSTL( m, 1, true, [0.5 0.5 0.5] );
hold on
obj_name = 'spraybottle.STL';
d = stlread(strcat(dir, obj_name));
RenderSTL(d,1,true,[0.5 0.5 0.5] );

pts = zeros( size(handrep.vIds,1), 3 );
norms = pts;
for k = 1:size(strConv,2)
    [pt, norm] = Reconstruct(m, handrep.vIds(k,:) - 18, handrep.vBarys(k,:) );
    pts(k,:) = pt;    %Not sure if this chunck of code works right
    norms(k,:) = norm;
end
%Draw normal vectors
quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );

%Points on hand
% save( strcat( dir, 'handrep', name, '.mat'), 'handrep' );
% 
% foo = load( strcat( dir, 'handrep', name, '.mat') );
% hrCheck = foo.handrep;
% mCheck = stlread( strcat( dir, 'Test_bHand3.STL') );
% RenderSTL( mCheck, 1, false, [0.5 0.5 0.5] );
% hold on;
% [pt, ptNorm] = Reconstruct(mCheck, hrCheck.vIds(1,:), hrCheck.vBarys(1,:) );
% pts(1,1:3) = pt;
% norms(1,:) = ptNorm;
% 
% quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );
% 
% fid = fopen( strcat(dir, name, '_vs.txt'), 'w');
% for k = 1:size(m.vertices,1)
%     fprintf(fid, '%0.6f %0.6f %0.6f ', m.vertices(k,:));
% end
% fclose(fid);