function mainArrowHop(systemP)

Ng = systemP.Ng;
Np = systemP.Np;

% Initialize particles on grid with no over lap
particles.ind = randperm( Ng*Ng, Np );
particles.pos  = ind2sub( Ng, paricles.ind ); 
particles.dir = randi(8, [Np, 1] );

% A particle move matrix (temp?)
% key:
% Particle dir: 1) N 2) NE 3) E 4) SE 5) S 6) SW 7) W 8) NW
% Grid dir: 1) N-S 2) NE-SW 3) E-W 4) SE-NW
% moveMat =  ( dx, dy, dind, blocked by 1, blocked by 2, grid block);
masterMat = ... 
  [ 0  1 -1     3  7  3]...
  [ 1  1 -1+Ng  4  8  4]...
  [ 0  1  Ng    5  1  1]...
  [ 1 -1  Ng+1  6  2  2]...
  [ 0 -1  1     7  3  3]...
  [-1 -1 -Ng+1  8  4  4]...
  [-1  0 -Ng    1  5  1]...
  [-1  1 -Ng-1  2  6  2];  

moveMat = ...
  [ 0  1; 1  1; 0  1; 1 -1;
    0 -1;-1 -1;-1  0;-1  1];  

blockVec = [ 3 4 1 2 3 4 1 2];
transMat = [...
  1 2 1 3;...
  1 2 3 2;...
  3 2 3 4;...
  5 4 3 4;...
  5 6 5 4;...
  5 6 7 6;...
  7 6 7 8;...
  1 8 7 8];

% Fill in grid with this info for faster look up
grid.occ      = zeros(Ng,Ng);
grid.obsType  = zeros(Ng,Ng);

grid.occ(particle.ind) = 1;
grid.obsType(particle.ind) = mod( particles.dir - 1, 4 ) + 1;

for t = 1:systemP.Nt

  randPick = randperm( Np );

  for ii = 1:Np
    pSelect = randPick(i);
    oldPos  = particles.pos(pSelect);
    tempPos = oldPos + moveMat( particles.dir(pSelect), : );
    tempPosPBC = mod( tempPos - [1 1] ), [Ng Ng] ) ) + [1 1] );

    if grid.occ( tempPosPBC(1), tempPosPBC(2) ) == 0
      particles.pos( pSelect ) = tempPosPBC;
      grid.occ( tempPosPBC(1), tempPosPBC(2) ) = 1;
      grid.occ( oldPos(1), oldPos(2) ) = grid.occ( oldPos(1), oldPos(2) ) - 1;
    elseif grid.obsType( tempPosPBC(1), tempPosPBC(2) ) == blockVec( particles.dir(pSelect) ;
      particles.pos(pSelect) = oldPos;
    else
      particles.pos( pSelect ) = tempPosPBC;
      grid.occ( tempPosPBC(1), tempPosPBC(2) ) = grid.occ( tempPosPBC(1) )...
      tempPosPBC(2) ) + 1;
      grid.occ( oldPos(1), oldPos(2) ) = grid.occ( oldPos(1), oldPos(2) ) - 1;
      particles.dir( pSelect ) = transMat( particles.dir( pSelect ),...
        grid.obsType( tempPosPBC(1), tempPosPBC(2) );
      end

    end
  end



        
      


  
