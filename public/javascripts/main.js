Event.observe(window, 'load', function() {
  if (!NiftyCheck()) {
      return;
  }
  RoundedTop('div.roundedTitle','#{Palette[9]}','#{Palette[1]}');
}, false);
