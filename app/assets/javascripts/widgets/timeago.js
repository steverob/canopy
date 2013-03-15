/*   Copyright (c) 2010-2011, Evergreen Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  Evergreen.Widgets.TimeAgo = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      if(Evergreen.I18n.language !== "en") {
        $.each($.timeago.settings.strings, function(index) {
          $.timeago.settings.strings[index] = Evergreen.I18n.t("timeago." + index);
        });
      }
    });
  };
})();
