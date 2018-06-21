clear
clc

global dSquareWidth;
global checkerboardSize;


dSquareWidth = 0.1;
checkerboardSize = [8,8];
v1 = [0.5,0.5,0];
v2 = [0.5,0,0];
v3 = [0,0,0];
v4 = [0,0.5,0]; 

ver = [v1,v2,v3,v4];
figure
%DrawTable(ver,true)

c = stlread('/home/reu3/NearContactStudy/InterpolateGrasps/Test_bHand3.STL');
%mOrig = stlread( strcat(dir, name, '.stl') );
RenderSTL( c, 1, true, [0.5 0.5 0.5] );
DrawTable(ver,true)
hold on
d = stlread('/home/reu3/NearContactStudy/InterpolateGrasps/Test_obj1.STL');
RenderSTL(d,1,true,[0.5 0.5 0.5] );
% vIds = [1 1 2; 2 3 4; 3 4 5];
% vBarys = vIds;
% for k = 1:size(vIds, 1 )
%     pt = Reconstruct(c, vIds(k,:), vBarys(k,:) );
%     plot3( pt(1), pt(2), pt(3), '*g', 'MarkerSize', 20 );
%     hold on
% end