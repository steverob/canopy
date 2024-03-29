/*   Copyright (c) 2010-2012, Evergreen Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("app.views.Publisher", function() {
  describe("standalone", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher({
        standalone: true
      });
    });

    it("hides the close button in standalone mode", function() {
      expect(this.view.$('#hide_publisher').is(':visible')).toBeFalsy();
    });
  });

  context("plain publisher", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe("#open", function() {
      it("removes the 'closed' class from the publisher element", function() {
        expect($(this.view.el)).toHaveClass("closed");
        this.view.open($.Event());
        expect($(this.view.el)).not.toHaveClass("closed");
      });
    });

    describe("#close", function() {
      beforeEach(function() {
        this.view.open($.Event());
      });

      it("removes the 'active' class from the publisher element", function(){
        this.view.close($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      })

      it("resets the element's height", function() {
        $(this.view.el).find("#status_message_fake_text").height(100);
        this.view.close($.Event());
        expect($(this.view.el).find("#status_message_fake_text").attr("style")).not.toContain("height");
      });
    });

    describe("#clear", function() {
      it("calls close", function(){
        spyOn(this.view, "close");

        this.view.clear($.Event());
        expect(this.view.close).toHaveBeenCalled();
      })

      it("clears all textareas", function(){
        _.each(this.view.$("textarea"), function(element){
          $(element).val('this is some stuff');
          expect($(element).val()).not.toBe("");
        });

        this.view.clear($.Event());

        _.each(this.view.$("textarea"), function(element){
          expect($(element).val()).toBe("");
        });
      })

      it("removes all photos from the dropzone area", function(){
        var self = this;
        _.times(3, function(){
          self.view.el_photozone.append($("<li>"))
        });

        expect(this.view.el_photozone.html()).not.toBe("");
        this.view.clear($.Event());
        expect(this.view.el_photozone.html()).toBe("");
      })

      it("removes all photo values appended by the photo uploader", function(){
        $(this.view.el).prepend("<input name='photos[]' value='3'/>")
        var photoValuesInput = this.view.$("input[name='photos[]']");

        photoValuesInput.val("3")
        this.view.clear($.Event());
        expect(this.view.$("input[name='photos[]']").length).toBe(0);
      })
    });
  });

  context("#toggleService", function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
      this.view = new app.views.Publisher();
    });

    it("toggles the 'dim' class on a clicked item", function() {
      var first = $(".service_icon").eq(0);
      var second = $(".service_icon").eq(1);

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeFalsy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();
    });

    describe("#_createCounter", function() {
      it("gets called in when you toggle service icons", function(){
        spyOn(this.view, '_createCounter');
        $(".service_icon").first().trigger('click');
        expect(this.view._createCounter).toHaveBeenCalled();
      });

      it("removes the 'old' .counter span", function(){
        spyOn($.fn, "remove");
        $(".service_icon").first().trigger('click');
        expect($.fn.remove).toHaveBeenCalled();
      });
    });

    describe("#_toggleServiceField", function() {
      it("gets called when you toggle service icons", function(){
        spyOn(this.view, '_toggleServiceField');
        $(".service_icon").first().trigger('click');
        expect(this.view._toggleServiceField).toHaveBeenCalled();
      });

      it("toggles the hidden input field", function(){
        expect($('input[name="services[]"]').length).toBe(0);
        $(".service_icon").first().trigger('click');
        expect($('input[name="services[]"]').length).toBe(1);
        $(".service_icon").first().trigger('click');
        expect($('input[name="services[]"]').length).toBe(0);
      });

      it("toggles the correct input", function() {
        var first = $(".service_icon").eq(0);
        var second = $(".service_icon").eq(1);

        first.trigger('click');
        second.trigger('click');

        expect($('input[name="services[]"]').length).toBe(2);

        first.trigger('click');

        var prov1 = first.attr('id');
        var prov2 = second.attr('id');

        expect($('input[name="services[]"][value="'+prov1+'"]').length).toBe(0);
        expect($('input[name="services[]"][value="'+prov2+'"]').length).toBe(1);
      });
    });
  });

  context("aspect selection", function(){
    beforeEach( function(){
      spec.loadFixture('status_message_new');

      this.radio_els = $('#publisher .dropdown li.radio');
      this.check_els = $('#publisher .dropdown li.aspect_selector');

      this.view = new app.views.Publisher();
      this.view.open();
    });

    it("initializes with 'all_aspects'", function(){
      expect(this.radio_els.first().hasClass('selected')).toBeFalsy();
      expect(this.radio_els.last().hasClass('selected')).toBeTruthy();

      _.each(this.check_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });
    });

    it("toggles the selected entry visually", function(){
      this.check_els.last().trigger('click');

      _.each(this.radio_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });

      expect(this.check_els.first().hasClass('selected')).toBeFalsy();
      expect(this.check_els.last().hasClass('selected')).toBeTruthy();
    });

    describe("#_updateSelectedAspectIds", function(){
      beforeEach(function(){
        this.li = $('<li data-aspect_id="42" />');
        this.view.$('.dropdown_list').append(this.li);
      });

      it("gets called when aspects are selected", function(){
        spyOn(this.view, "_updateSelectedAspectIds");
        this.check_els.last().trigger('click');
        expect(this.view._updateSelectedAspectIds).toHaveBeenCalled();
      });

      it("removes a previous selection and inserts the current one", function() {
        var selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('all_aspects');

        this.li.trigger('click');

        selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('42');
      });

      it("toggles the same item", function() {
        expect(this.view.$('input[name="aspect_ids[]"]').length).toBe(1);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"]').length).toBe(1);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"]').length).toBe(0);
      });

      it("keeps other fields with different values", function() {
        var li2 = $("<li data-aspect_id=99></li>");
        this.view.$('.dropdown_list').append(li2);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"]').length).toBe(1);

        li2.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"]').length).toBe(2);
      });
    });

    describe("#_addHiddenAspectInput", function(){
      it("gets called when aspects are selected", function(){
        spyOn(this.view, "_addHiddenAspectInput");
        this.check_els.last().trigger('click');
        expect(this.view._addHiddenAspectInput).toHaveBeenCalled();
      });

      it("adds a hidden input to the form", function(){
        var id = 42;

        this.view._addHiddenAspectInput(id);
        var input = this.view.$('input[name="aspect_ids[]"][value="'+id+'"]');

        expect(input.length).toBe(1);
        expect(input.val()).toBe('42');
      });
    });
  });
});
