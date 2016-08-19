% set-up animations
function recH = setupAnim(Ng)
  clf
  ax=gca;axis square;ax.XGrid='on';ax.YGrid='on';
  ax.XLim=[0.5 Ng+0.5];ax.YLim=[0.5 Ng+0.5];
  ax.XTick=[0:ceil(Ng/20):Ng];
  ax.YTick=ax.XTick;
  ax.XLabel.String='x position';ax.YLabel.String='y position';
  ax.FontSize=14;
end

