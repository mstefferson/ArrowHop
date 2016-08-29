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
particles.ind = randperm( Ng*Ng, Np )';
particles.pos = zeros( Np, 2 );
[particles.pos(:,1), particles.pos(:,2)] = ind2sub( [Ng Ng], particles.ind );
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
    Mov = VideoWriter(animation.MovStr);
    Mov.FrameRate = 4;
    open(Mov);
  end
  
end

% NEED TO FIGURE OUT COLOR WHEEL AND PLOT IT!!!

% Fill in grid with this info for faster look up
% Track grid occ and nematic order in a double list
% Track polar species at each grid point

gridPolarStore = zeros( Ng*Ng, 4 ); % gridspace: occ, # type 1, 2, 3...8
gridPolarStore( particles.ind, 1 ) = particles.dir == 1;
gridPolarStore( particles.ind, 2 ) = particles.dir == 2;
gridPolarStore( particles.ind, 3 ) = particles.dir == 3;
gridPolarStore( particles.ind, 4 ) = particles.dir == 4;
gridPolarStore( particles.ind, 5 ) = particles.dir == 5;
gridPolarStore( particles.ind, 6 ) = particles.dir == 6;
gridPolarStore( particles.ind, 7 ) = particles.dir == 7;
gridPolarStore( particles.ind, 8 ) = particles.dir == 8;

% Occ and Nematic. Not used if no interations
gridOcc = zeros( Ng*Ng, 2 );
gridOcc( particles.ind, 1 ) = 1;
gridOcc( particles.ind, 2 ) =  mod( particles.dir - 1, 4 ) + 1;

try
  for t = 1:time.Nt 
    % move everythin
    randPick = randperm( Np );
    rVec     = rand(Np,1);
    
    for ii = 1:Np
      pSelect = randPick(ii);
      dirNem = mod( particles.dir( pSelect ) - 1, 4 ) + 1;
      oldPos  = particles.pos(pSelect,:);
      newPos = oldPos;
      oldDir = particles.dir(pSelect,:);
      newDir = oldDir;
      
      p2 = vHopProb;
      p3 = p2 + bHopParProb;
      p4 = p3 + bHopPerpProb;
      p5 = p4 + bRotProb;
      
      if ( 0 <= rVec(ii) ) && ( rVec(ii) < p2 ) % v Hop
        newPos = oldPos + moveMat( particles.dir(pSelect), : );
        newPos = mod( newPos - [1 1] , [Ng Ng] ) + [1 1] ;
      elseif ( p2 <= rVec(ii) ) && ( rVec(ii) < p3 ) % // Hop
        newPos = newPos + flipV( randi(2) ) .* diffMatPar( dirNem, : ) ;
        newPos = mod( newPos - [1 1] , [Ng Ng] ) + [1 1] ;
      elseif ( p3 <= rVec(ii) ) && ( rVec(ii) < p4 ) % Perp Hop
        newPos = newPos + flipV( randi(2) ) .* diffMatPerp( dirNem, : ) ;
        newPos = mod( newPos - [1 1] , [Ng Ng] ) + [1 1] ;
      elseif ( p4 <= rVec(ii) ) && ( rVec(ii) <= p5 ) % Rot Hop
        newDir = ...
          mod( particles.dir( pSelect ) + flipV( randi(2) ) - 1, 8) + 1;
      end

      tpX = newPos(1);
      tpY = newPos(2);
      
      oldInd = particles.ind(pSelect);
      newInd = sub2ind( [Ng Ng], tpX, tpY );
      
      % Remove it from the grid so it doesn't interact with itself     
      gridOcc( oldInd, 1 ) = gridOcc( oldInd, 1 ) - 1;
      if gridOcc( oldInd, 1 ) == 0;
        gridOcc(oldInd , 2 ) = 0;
      end   

      gridPolarStore( oldInd, oldDir ) = gridPolarStore( oldInd, oldDir ) - 1;
      
      if flags.interactions
        % Empty
        if gridOcc( newInd, 1 ) == 0
          % Update particle positions
          particles.pos( pSelect, : ) = newPos;
          particles.ind( pSelect ) = newInd;
          particles.dir( pSelect ) = newDir;
          %Update gridOcc
          gridOcc( newInd, 1 ) = gridOcc( newInd, 1 ) + 1;
          gridOcc( newInd, 2 ) = mod( particles.dir(pSelect) - 1, 4 ) + 1;
        % Particle Blocked
        elseif gridOcc( newInd, 2 ) == blockVec( newDir )
          % Update particle positions
          newInd = oldInd;
          particles.pos( pSelect, : ) = oldPos;
          particles.ind( pSelect ) = newInd;
          particles.dir( pSelect ) = newDir;
          
          %Update gridOcc
          gridOcc( newInd, 1 ) = gridOcc( newInd, 1 ) + 1;
          gridOcc( oldInd, 2 ) = mod( newDir - 1, 4 ) + 1;
        % Can move, Not empty  
        else           
          % Update particle positions
          newDir = transMat( newDir, gridOcc(newInd,2) ); 
          particles.pos( pSelect, : ) = newPos;
          particles.ind( pSelect ) = newInd;
          particles.dir( pSelect ) = newDir;
          %Update gridOcc
          gridOcc( newInd, 1 ) = gridOcc( newInd, 1 ) + 1;
        end
      else % No interactions
        % Move it and update particles
        particles.pos( pSelect, : ) = newPos;
        particles.dir( pSelect ) = newDir;
      end

      % Change occupancy
      gridPolarStore( newInd, newDir ) = gridPolarStore( newInd, newDir ) + 1;
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




