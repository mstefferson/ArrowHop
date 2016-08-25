% add path
addpath('./src');

% Initialize parameters
initParams();

% Find run lengths
numTr = systemP.numTr;
numFf = length( systemP.ffp );
numHpar = length( particles.bHopParProb );

numParams = numTr * numFf * numHpar;
paramMat = zeros( numParams, 3 );
for i = 1:numTr
  for j = 1:numFf
    for k = 1:numHpar
      rowind = 1 + (i-1) + (j-1) * numTr + (k-1) * numTr * numFf;
      paramMat( rowind, 1 ) = (i-1) + systemP.runID;
      paramMat( rowind, 2 ) = systemP.ffp(j);
      paramMat( rowind, 3 ) = particles.bHopParProb(k);
    end
  end
end


% For some reason, param_mat gets "sliced". Create vectors to get arround
% this
paramRunID  = paramMat(:,1);
paramFFp    = paramMat(:,2);
paramHopPar = paramMat(:,3);

% Run main code

for ii = 1: numParams
  runID = paramRunID(ii);
  systemP.ffp   = paramFFp(ii);
  systemP.Np = round( systemP.ffp .* systemP.Ng .^ 2 );
  particles.bHopParProb = paramHopPar(ii);
  particles.bHopPerpProb = particles.bHopParProb / 2;
  particles.bRotProb = 6 .* particles.bHopParProb;
  
  filestring=['AH',...
    '_vProb',num2str(particles.vHopProb),...
    '_hopPar',num2str(particles.bHopParProb),...
    '_ffp',num2str(systemP.ffp), ...
    '_ng', num2str(systemP.Ng),...
    '_nt',num2str(time.Nt),...
    '_trec', num2str(time.tRec),...
    '_t', num2str(systemP.trID,'%.2d'),'.',num2str(runID,'%.2d') ];
  
  fprintf(' Running %s \n\n', filestring );
  
  if flags.movie
    animation.MovStr = [filestring '.avi'];
  end
  tid = tic;
  mainArrowHop( filestring, systemP, particles, time, flags, animation );
  runT = toc(tid);
  fprintf( 'Run time %f (sec) \n\n', runT);
end
