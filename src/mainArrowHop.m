function mainArrowHop( filename, systemP, particles, time, flags, animation )

% Normalize probabilities
probNorm = particles.vHopProb + particles.bHopParProb +...
  particles.bHopPerpProb + particles.bRotProb + particles.doNothingProb;
vHopProb = particles.vHopProb ./ probNorm;
bHopParProb = particles.bHopParProb ./ probNorm;
bHopPerpProb = particles.bHopPerpProb ./ probNorm;
bRotProb = particles.bRotProb ./ probNorm;
doNothingProb = particles.doNothingProb ./ probNorm;

Ng = systemP.Ng;
Np = systemP.Np;

if flags.interactions == 0
  onesRep = ones(Np,2);
  NgRep = Ng .* onesRep;
end

% Initialize particles on grid with no over lap
particles.Np  = systemP.Np;
particles.ind = randperm( Ng*Ng, Np );
particles.pos = zeros( Np, 2 );
[particles.pos(:,1), particles.pos(:,2)] = ind2sub( Ng, particles.ind );
particles.dir = randi(8, [Np, 1] );

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

% diffusion matrix (dx1, dy1)
flipV = [-1 1];
diffMatPar = [...
  0  1; ...
  1  1; ...
  1  0; ...
  1 -1;];
diffMatPerp = [...
  1  0; ...
  1 -1; ...
  0  1; ...
  1  1];

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
partitions = length( blockVec );
animation.colorwheel = makeColorwheel( partitions );

% Place objects
if flags.animate == 1
  setupAnim(Ng);
  recH = initAnim( particles, animation);
  
  % Set-up movies
    if flags.movie
      Fig = gcf;
      %Fig.Position = FigPos;
      Mov = VideoWriter(animation.MovStr);
      Mov.FrameRate = 4;
      open(Mov);
    end

end



% NEED TO FIGURE OUT COLOR WHEEL AND PLOT IT!!!

% Fill in grid with this info for faster look up
grid.occ      = zeros(Ng,Ng);
grid.obsType  = zeros(Ng,Ng);

grid.occ(particles.ind) = 1;
grid.obsType(particles.ind) = mod( particles.dir - 1, 4 ) + 1;

try
  for t = 1:time.Nt
    
    % move everythin
    randPick = randperm( Np );
    rVec     = rand(Np,1);

    for ii = 1:Np
      pSelect = randPick(ii);
      dirNem = mod( particles.dir( pSelect ) - 1, 4 ) + 1;
      oldPos  = particles.pos(pSelect,:);
      tempPos = oldPos;
      oldDir = particles.dir(pSelect,:);
      newDir = oldDir;

      p1 = 0;
      p2 = vHopProb;
      p3 = p2 + bHopParProb;
      p4 = p3 + bHopPerpProb;
      p5 = p4 + bRotProb;
      if p1 <= rVec(ii) && rVec(ii) < p1 + vHopProb
        tempPos = oldPos + moveMat( particles.dir(pSelect), : );
      elseif p2 <= rVec(ii) && rVec(ii) < p2 +bHopParProb
        tempPos = tempPos + flipV( randi(2) ) .* diffMatPar( dirNem, : ) ;
      elseif p3 <= rVec(ii) && rVec(ii) < p3 + bHopPerpProb
        tempPos = tempPos + flipV( randi(2) ) .* diffMatPerp( dirNem, : ) ;
      elseif p4 <= rVec(ii) && rVec(ii) < p4 + bRotProb
        newDir = ...
          mod( particles.dir( pSelect ) + flipV( randi(2) ) - 1, 8) + 1;
      end
      %keyboard
      tempPosPBC = mod( tempPos - [1 1] , [Ng Ng] ) + [1 1] ;
      tpX = tempPosPBC(1);
      tpY = tempPosPBC(2);
      
      if flags.interactions
        % open spot
        if grid.occ( tpX, tpY ) == 0
          particles.pos( pSelect, : ) = tempPosPBC;
          grid.occ( tpX, tpY ) = grid.occ( tpX, tpY ) + 1;
          grid.occ( oldPos(1), oldPos(2) ) = grid.occ( oldPos(1), oldPos(2) ) - 1;
          grid.obsType( tpX, tpY ) = ...
            obstParDir( particles.dir( pSelect) );
          particles.dir( pSelect ) = transMat( newDir ,...
            grid.obsType( tpX, tpY ) );
          % spot with obstacle, but not blocked
        elseif grid.obsType( tpX, tpY ) ~= blockVec( newDir );
          particles.pos( pSelect, : ) = tempPosPBC;
          grid.occ( tpX, tpY ) = ...
            grid.occ( tpX, tpY ) + 1;
          grid.occ( oldPos(1), oldPos(2) ) = ...
            grid.occ( oldPos(1), oldPos(2) ) - 1;
          if grid.occ(tpX, tpY) > 1
            particles.dir( pSelect ) = transMat( newDir ,...
              grid.obsType( tpX, tpY ) );
          else
            particles.dir( pSelect ) = newDir;
          end
        end
      else
        particles.pos(pSelect,:) = tempPosPBC;
        particles.dir(pSelect)  = newDir;
      end
      
      if grid.occ( oldPos(1), oldPos(2) ) == 0
        grid.obsType( oldPos(1), oldPos(2) ) = 0;
      end
    end % particles
    
    if flags.animate 
      updateAnim( recH, particles, animation )
      if flags.movie
        if mod( t, time.tRec ) == 0
          drawnow;
          pause(0.001);
          Fr = getframe(Fig);
          writeVideo(Mov,Fr);
        end % rec
      end % movie flag
    end %animate
  end % time
  
catch err
  disp(err)
  keyboard
end % try catch

 if flags.movie
    close(Mov);
    movefile(animation.MovStr, './movies')
  end




