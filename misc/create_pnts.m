function [ newPosBalls ] = create_pnts( baseDirName_input, baseDirName_output)
    if ~exist([baseDirName_output,'/512pntHull.mat'],'file')~=0
        % For the PRIvol use:
        % reading the hull.shape AFNI file (which in in PRI m)
        [hull.pnt, hull.tri] = IT_readHull([baseDirName_input,'/hull.shape']);
        % NOTE pnt is size(XXX,6) the first 3 columns are the xyz location in PRI
        % and the 4,5,6 columns are their normals.

        % cmHull is the same hull.shape in cm instead of m
        cmHull.pnt(:,1:3) = hull.pnt(:,1:3)*100;
        cmHull.pnt(:,4:6) = hull.pnt(:,4:6);% the normals are unit size, no neet to *100
        cmHull.tri = hull.tri;% this should not be changed!

        % plotting mesh via ft, in PRI cm
        PRIvol.pnt = cmHull.pnt(:,1:3);
        PRIvol.tri = cmHull.tri+1;% +1 to transfer 0 from c to 1 in matlab
        ft_plot_mesh(PRIvol)
        hold on
        newPosBalls=csvread([baseDirName_output,'/final_transformed_pnts.csv']);
        scatter3(newPosBalls(:,1),newPosBalls(:,2),newPosBalls(:,3),'*r')
        indSelectedBalls = 1:length(newPosBalls);
        save([baseDirName_output,'/512pntHull.mat'], 'PRIvol','newPosBalls','indSelectedBalls');
    else
        load([baseDirName_output,'/512pntHull.mat'])
    end

end
