% runArrowHop
systemP.Ng = 20; % Number of grid points
systemP.Np = 50; % Number of particles
systemP.Nt = 400; % Time points

particles.size = ...
  [0.25 0.75; 0.75 0.75; 0.75 0.25; 0.75 0.75];      % size
particles.curvature = ...
  [1 0; 0 1; 1 0; 1 1];   % circles

% flags
flags.interactions = 1;
flags.animate = 1;


systemP.animPause = 0.01;
mainArrowHop(systemP,particles,flags);

