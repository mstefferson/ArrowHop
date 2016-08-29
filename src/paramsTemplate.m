% flags
flags.interactions = 1;
flags.animate = 1; % Run animations
flags.movie = 0; % Save movies
flags.recPos = 0; % Not started

% runArrowHop
systemP.numTr = 1; % Number of trails
systemP.trID  = 1; % trial ID
systemP.runID = 1; % run  ID
systemP.Ng = 20; % Number of grid points
systemP.ffp = [1]; % Filling fractoin of particles [0,1]

% time
time.Nt = 10; % Time points
time.tRec =  1; % record position/record movie

% particle parameters
particles.type = 'rods'; %rods change diffusion to that of rods, random does not
particles.vHopProb = 1; % prob velocity hop
particles.bHopParProb = [0.5]; % prob of browian hop along parallel dir
particles.bHopPerpProb = 0.25;
particles.bRotProb = 0.5;
particles.doNothingProb = 0;

% animation stuff
animation.psize = ...
  [0.25 0.75; 0.75 0.75; 0.75 0.25; 0.75 0.75];      % size
animation.curvature = ...
  [1 0; 0 1; 1 0; 1 1];   % circles
animation.pauseT = 0.1;% flags
