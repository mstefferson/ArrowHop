function updateAnim( recH, particles, animation )

for ii = 1:particles.Np
  % reset position
  dirT = mod( particles.dir(ii) - 1, 4 ) + 1;
  set( recH(ii) ,'Position', ...
    [particles.pos(ii,1) - animation.psize(dirT,1) /2 , ...
    particles.pos(ii,2) - animation.psize(dirT,2) /2,...
    animation.psize(dirT,:)], 'Curvature', animation.curvature(dirT,:), ...
    'FaceColor', animation.colorwheel( particles.dir(ii), : ) );
end
drawnow
pause( animation.pauseT )

