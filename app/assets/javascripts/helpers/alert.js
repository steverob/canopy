Evergreen.Alert = {
  faceboxTemplate:
    '<div id="Evergreen_alert">' +
      '<div class="span-12 last">' +
        '<div id="facebox_header">' +
          '<h4>' +
          '<%= title %>' +
          '</h4>' +
        '</div>' +
        '<%= content %>' +
      '</div>' +
    '</div>',

  show: function(title, content) {
    $(_.template(this.faceboxTemplate, {
      title: title,
    content: content
    })).appendTo(document.body);

    $.facebox({
      div: "#Evergreen_alert"
    }, "Evergreen_alert");
  }
};

$(function() {
  $(document).bind("close.facebox", function() {
    $("#Evergreen_alert").remove();
  });
});
