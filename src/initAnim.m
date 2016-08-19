% initialize animation and return vector of rectangle handles
function recH = initAnim( particles, animation )
  recH = zeros(1,particles.Np);
  for ii = 1:particles.Np
    dirT = mod( particles.dir(ii) - 1, 4 ) + 1;
    recH(ii) = rectangle('Position', ...
      [particles.pos(ii,1) - animation.psize(dirT,1) /2 , ...
      particles.pos(ii,2) - animation.psize(dirT,2) /2,...
      animation.psize(dirT,:)], 'Curvature', animation.curvature(dirT,:), ...
      'FaceColor', animation.colorwheel( particles.dir(ii), : ) );
  end
  pause( animation.pauseT )
end


