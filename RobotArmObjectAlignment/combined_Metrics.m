clear
clc

global dir strhand strobj
% Personal computer
%dir = '/home/yhong/NearContactStudy/InterpolateGrasps/pregrasp_pose_data/';
% Lab computer
dir = '/home/yihernong/Documents/NearContactStudy/InterpolateGrasps/pregrasp_pose_data/';
% Laptop 
% dir = '/home/yiherngong/NearContactStudy/InterpolateGrasps/pregrasp_pose_data/';

strhand = 'Test_bHand3';
strobj = 'spraybottle';

% Construct handrep
STLhand = strcat(dir, strhand, '.STL');
STLobj = strcat(dir, strobj, '.STL');

% Read in Hand and Object, generate faces and vertices for each stl
m_Hand = stlread(STLhand);
m_Obj = stlread(STLobj);

% 
handrep = struct;
strConv = { 'palm', 'palm_left', 'palm_right', ...
            'thumb_inner', ...
            'thumb_outer1', 'thumb_outer2',  'thumb_outer3', ...
            'finger1_inner', ...
            'finger1_outer1', 'finger1_outer2', 'finger1_outer3', ...
            'finger2_inner', ...
            'finger2_outer1', 'finger2_outer2', 'finger2_outer3'};
%strConv = { 'palm', 'finger1_inner', 'finger1_outer', 'finger2_inner', 'finger2_outer'};
handrep.names = strConv;
handrep.vIds = zeros( length( strConv ), 3 );
handrep.vBarys = zeros( length( strConv ), 3 );
handrep.vNorms = zeros( length( strConv ), 3 );

% Load in targeted vertices from textfile and convert them into barycentric
% coordinates
for k = 1:size(strConv,2)
    strBase = strcat(dir, strConv{k});
    [m, ids, barys, norms] = PointsToBary( STLhand, strcat(strBase, '.txt'), strBase);
    handrep.vIds(k,:) = ids(1,:); %+ 18; % Account for wacky v number (ASK!)
    handrep.vBarys(k,:) = barys(1,:);
    handrep.vNorms(k,:) = norms(1,:); 
end

pts = zeros(size(handrep.vIds, 1), 3); % vertices
norms = pts; % normals of vertices
for k = 1:size( strConv, 2 )
    [pt, norm] = Reconstruct(m, handrep.vIds(k,:) , handrep.vBarys(k,:) ); % minus 18 on handrep vIds if there is +18 above
    % pts = [pt pt+norm * 0.1];
    pts(k,:) = pt;
    norms(k,:) = norm;
end

RenderSTL(m, 1, true, [0.5, 0.5, 0.5]); %Draw hand. True means hold on
hold on
%Draw arrows for normal of each point
quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );
hold on
% Save handrep in .mat file
save( strcat( dir, 'handrep', strhand, '.mat'), 'handrep' );

% %% Load handrep and other hand position to determine corresponsing barys
% and normals
% % load .mat file
% load_hr = load( strcat(  dir, 'handrep', strhand, '.mat') );
% hr = load_hr.handrep;
% 
% % Read an STL file and use handrep to generate pts and normals
% strnewHand = 'Test_bHand2';
% STLnewHand = strcat(strnewHand, '.STL');
% m_newHand = stlread(STLnewHand);
% clf
% RenderSTL(m_newHand, 1, true, [0.5 0.5 0.5]); %hold on
% %Calculate pts and normals
% for k = 1:size(hrCheck.vIds, 1 )
%     [pt, ptNorm] = Reconstruct(m_newHand, hr.vIds(k,:), hr.vBarys(k,:) );
%     pts(k,:) = pt;
%     norms(k,:) = ptNorm;
% end
% 
% %Draw pts and normals
% quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );

%% Run points for objects
fnObj = strcat(dir, strobj, '_pts', '.txt');
fnwObj = strcat(dir, strobj);
obj_arr = dlmread(fnObj);
objvIds = zeros(size(obj_arr,1), 3);
objbarys = objvIds;

[objM, objidsOut, objbarysOut, objnormsOut] = PointsToBary( STLobj, fnObj, fnwObj);
for k = 1:size(obj_arr,1)
    objvIds(k,:) = objidsOut(k,:);
    objbarys(k,:) = objbarysOut(k,:);
end

RenderSTL(objM, 1, true, [0.5 0.5 0.5]);
hold on
objpts = zeros( size( objvIds, 1 ), 3 );
objnorms = objpts;
for p = 1:size( obj_arr, 1 )
    [obj_pt,obj_norm] = Reconstruct(objM, objvIds(p,:), objbarys(p,:) );
    objpts(p,:) = obj_pt;
    objnorms(p,:) = obj_norm;
end

quiver3( objpts(:,1), objpts(:,2), objpts(:,3), objnorms(:,1), objnorms(:,2), objnorms(:,3) );    
dlmwrite( strcat(dir, strobj, '_ptsNorms.txt'), [objpts objnorms] );

%% Draw Table
global dSquareWidth;
global checkerboardSize;
dSquareWidth = 0.1;
checkerboardSize = [8,8];
v1 = [0.5,0.5,0];
v2 = [0.5,0,0];
v3 = [0,0,0];
v4 = [0,0.5,0]; 
ver = [v1,v2,v3,v4];
DrawTable(ver,true)
%% Run All Metrics
pLeft = Reconstruct(m, handrep.vIds(2,:), handrep.vBarys(2,:));
pRight = Reconstruct(m, handrep.vIds(3,:), handrep.vBarys(3,:) );
vPalm = pRight - pLeft;
handWidth = sqrt( sum(vPalm.^2) ) * 1.5;
handHeight = 0.01 * handWidth;

[metrics, mPalm, mFinger, mPinch] = CalcAllMetrics(m, handrep, handWidth, objpts, objnorms, handHeight);

% metrics = ProcessTrajectory(dir, 20,handrep, handWidth,
% handHeight,strobj);  %this is not working with one hand pose, change it
% the code so that it accepts one frame instead of multiple frames
% dlmwrite( strcat( dir, 'metrics.csv' ), metrics );