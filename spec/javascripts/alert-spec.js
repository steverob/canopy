describe("Evergreen.Alert", function() {
  beforeEach(function() {
    spec.loadFixture("aspects_index");

    $(document).trigger("close.facebox");
  });

  afterEach(function() {
    $("#facebox").remove();

  });


  describe("on widget ready", function() {
    it("should remove #Evergreen_alert on close.facebox", function() {
      Evergreen.Alert.show("YEAH", "YEAHH");
      expect($("#Evergreen_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
      expect($("#Evergreen_alert").length).toEqual(0);
    });
  });

  describe("alert", function() {
    it("should render a mustache template and append it the body", function() {
      Evergreen.Alert.show("YO", "YEAH");
      expect($("#Evergreen_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
    });
  });
});
