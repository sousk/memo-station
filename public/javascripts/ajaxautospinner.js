Ajax.Responders.register({
  onCreate: function() {
    if (Ajax.activeRequestCount > 0)
      Element.show('ajaxautospinner');
  },

  onComplete: function() {
    if (Ajax.activeRequestCount == 0)
      Element.hide('ajaxautospinner');
  }
});
