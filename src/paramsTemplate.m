% flags
flags.interactions = 1;
flags.animate = 1;

% runArrowHop
systemP.Ng = 20; % Number of grid points
systemP.Np = 10; % Number of particles
systemP.Nt = 100; % Time points

% particle parameters
particles.type = 'rods';

% animation stuff
animation.psize = ...
  [0.25 0.75; 0.75 0.75; 0.75 0.25; 0.75 0.75];      % size
animation.curvature = ...
  [1 0; 0 1; 1 0; 1 1];   % circles
animation.pauseT = 0.01;

