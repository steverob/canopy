(function() {
  var Stream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, stream) {
      if( Evergreen.backboneEnabled() ){ return }

      $.extend(self, {
        stream: $(stream),
        mainStream: $(stream).find('#main_stream'),
        headerTitle: $(stream).find('#aspect_stream_header > h3')
      });
    });

    this.globalSubscribe("stream/reloaded stream/scrolled", function() {
      self.publish("widget/ready", self.stream);
    });

    this.empty = function() {
      self.mainStream.empty();
      self.headerTitle.text(Evergreen.I18n.t('stream.no_aspects'));
    };

    this.setHeaderTitle = function(newTitle) {
      self.headerTitle.text(newTitle);
    };
  };

  if(!Evergreen.backboneEnabled()) {
    Evergreen.Widgets.Stream = Stream;
  }
})();
