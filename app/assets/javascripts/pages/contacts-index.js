Evergreen.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    $('.conversation_button').tooltip({placement: 'bottom'});
  });

};
