% Builds a rbg colorwheel with given number of partitions

function [colorwheel] = makeColorwheel( partitions )
  
  hues = 0 : 1/partitions : 1 - 1/partitions;
  HSV = [hues' ones(partitions,1) ones(partitions,1) ];
  hsv2rgb( HSV );
  colorwheel = hsv2rgb( HSV );
  
end

