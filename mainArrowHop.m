function mainArrowHop( systemP, particles, flags )

Ng = systemP.Ng;
Np = systemP.Np;

if flags.interactions == 0
  onesRep = ones(Np,2);
  NgRep = Ng .* onesRep;
end
% Initialize particles on grid with no over lap
particles.ind = randperm( Ng*Ng, Np );
particles.pos = zeros( Np, 2 );
[particles.pos(:,1), particles.pos(:,2)] = ind2sub( Ng, particles.ind );
particles.dir = randi(8, [Np, 1] );

psize = particles.size;

% A particle move matrix (temp?)
% key:
% Particle dir: 1) N 2) NE 3) E 4) SE 5) S 6) SW 7) W 8) NW
% Grid dir: 1) N-S 2) NE-SW 3) E-W 4) SE-NW
% moveMat =  ( dx, dy, dind, blocked by 1, blocked by 2, grid block);

moveMat = ...
  [ 0  1; 1  1; 1 0; 1 -1;
  0 -1;-1 -1;-1 0;-1  1];

blockVec = [ 3 4 1 2 3 4 1 2];

% obstable - particle direction mat
obstParDir = [ 1 2 3 4 1 2 3 4];
% transition matrix. what do particles flip to after making a transition
% from a initial direction (row 1:8) to an obstable direction (column 1:4)
transMat = [...
  1 2 1 8;...
  1 2 3 2;...
  3 2 3 4;...
  5 4 3 4;...
  5 6 5 4;...
  5 6 7 6;...
  7 6 7 8;...
  1 8 7 8];

% Color wheel
section = 8;
hues = 0 : 1/section : 1 - 1/section;
HSV = [hues' ones(section,1) ones(section,1) ];
hsv2rgb( HSV );
colorwheel = hsv2rgb( HSV );

% Place objects
if flags.animate == 1
  clf
  ax=gca;axis square;ax.XGrid='on';ax.YGrid='on';
  ax.XLim=[0.5 Ng+0.5];ax.YLim=[0.5 Ng+0.5];
  ax.XTick=[0:ceil(Ng/20):Ng];
  ax.YTick=ax.XTick;
  ax.XLabel.String='x position';ax.YLabel.String='y position';
  ax.FontSize=14;
  recH = zeros(1,Np);

  for ii = 1:Np
    dirT = mod( particles.dir(ii) - 1, 4 ) + 1;
    recH(ii) = rectangle('Position', ...
      [particles.pos(ii,1) - psize(dirT,1) /2 , ...
      particles.pos(ii,2) - psize(dirT,2) /2,...
      psize(dirT,:)], 'Curvature', particles.curvature(dirT,:), ...
      'FaceColor', colorwheel( particles.dir(ii), : ) );
  end
  pause(systemP.animPause)
  
end

% NEED TO FIGURE OUT COLOR WHEEL AND PLOT IT!!!

% Fill in grid with this info for faster look up
grid.occ      = zeros(Ng,Ng);
grid.obsType  = zeros(Ng,Ng);

grid.occ(particles.ind) = 1;
grid.obsType(particles.ind) = mod( particles.dir - 1, 4 ) + 1;

try
  for t = 1:systemP.Nt
    
    randPick = randperm( Np );
    
    if flags.interactions
    for ii = 1:Np
      pSelect = randPick(ii);
      oldPos  = particles.pos(pSelect,:);
      tempPos = oldPos + moveMat( particles.dir(pSelect), : );
      tempPosPBC = mod( tempPos - [1 1] , [Ng Ng] ) + [1 1] ;
      
      tpX = tempPosPBC(1);
      tpY = tempPosPBC(2);
      
      % open spot
      if grid.occ( tpX, tpY ) == 0
        particles.pos( pSelect, : ) = tempPosPBC;
        grid.occ( tpX, tpY ) = 1;
        grid.occ( oldPos(1), oldPos(2) ) = grid.occ( oldPos(1), oldPos(2) ) - 1;
        grid.obsType( tpX, tpY ) = ...
          obstParDir( particles.dir( pSelect) );
      % spot with obstacle, but not blocked 
      elseif grid.obsType( tpX, tpY ) ~= blockVec( particles.dir(pSelect) );
        particles.pos( pSelect, : ) = tempPosPBC;
        grid.occ( tpX, tpY ) = ...
          grid.occ( tpX, tpY ) + 1;
        grid.occ( oldPos(1), oldPos(2) ) = grid.occ( oldPos(1), oldPos(2) ) - 1;
        particles.dir( pSelect ) = transMat( particles.dir( pSelect ),...
          grid.obsType( tpX, tpY ) );
      end
      
      if grid.occ( oldPos(1), oldPos(2) ) == 0
        grid.obsType( oldPos(1), oldPos(2) ) = 0;
      end
      %       keyboard      
    end % loop over particles
    
    else
       particles.pos = mod( particles.pos + ...
         moveMat( particles.dir, : ) - onesRep , NgRep ) + onesRep;
    end % interactions
    
    if flags.animate == 1
      for ii = 1:Np
        % reset position
        dirT = mod( particles.dir(ii) - 1, 4 ) + 1;
        set( recH(ii) ,'Position', ...
          [particles.pos(ii,1) - psize(dirT,1) /2 , ...
          particles.pos(ii,2) - psize(dirT,2) /2,...
          psize(dirT,:)], 'Curvature', particles.curvature(dirT,:), ...
          'FaceColor', colorwheel( particles.dir(ii), : ) );
      end
      drawnow
      pause(systemP.animPause)
    end %animate
  end % time
  
catch err
  disp(err)
%   keyboard
end






