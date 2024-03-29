describe("app.views.Feedback", function(){
  beforeEach(function(){
   loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    Evergreen.I18n.loadLocale({stream : {
      'like' : "Like",
      'unlike' : "Unlike",
      'public' : "Public",
      'limited' : "Limted"
    }})

    var posts = $.parseJSON(spec.readFixture("stream_json"));

    this.post = new app.models.Post(posts[0]);
    this.view = new app.views.Feedback({model: this.post});
  });


  describe("triggers", function() {
    it('re-renders when the model triggers feedback', function(){
      spyOn(this.view, "postRenderTemplate")
      this.view.model.interactions.trigger("change")
      expect(this.view.postRenderTemplate).toHaveBeenCalled()
    })
  })

  describe(".render", function(){
    beforeEach(function(){
      this.link = function(){ return this.view.$("a.like"); }
      this.view.render();
    })

    context("likes", function(){
      it("calls 'toggleLike' on the target post", function(){
        loginAs(this.post.interactions.likes.models[0].get("author"))
        this.view.render();
        spyOn(this.post.interactions, "toggleLike");
        this.link().click();
        expect(this.post.interactions.toggleLike).toHaveBeenCalled();
      })

      context("when the user likes the post", function(){
        it("the like action should be 'Unlike'", function(){
          spyOn(this.post.interactions, "userLike").andReturn(factory.like());
          this.view.render()
          expect(this.link().text()).toContain(Evergreen.I18n.t('stream.unlike'))
        })
      })


      context("when the user doesn't yet like the post", function(){
        beforeEach(function(){
          this.view.model.set({user_like : null});
          this.view.render();
        })

        it("the like action should be 'Like'", function(){
          expect(this.link().text()).toContain(Evergreen.I18n.t('stream.like'))
        })

        it("allows for unliking a just-liked post", function(){
          // callback stuff.... we should fix this

          // expect(this.link().text()).toContain(Evergreen.I18n.t('stream.like'))

          // this.link().click();
          // expect(this.link().text()).toContain(Evergreen.I18n.t('stream.unlike'))

          // this.link().click();
          // expect(this.link().text()).toContain(Evergreen.I18n.t('stream.like'))
        })
      })
    })

    context("when the post is public", function(){
      beforeEach(function(){
        this.post.attributes.public = true;
        this.view.render();
      })

      it("shows 'Public'", function(){
        expect($(this.view.el).html()).toContain(Evergreen.I18n.t('stream.public'))
      })

      it("shows a reshare_action link", function(){
        expect(this.view.$("a.reshare")).toExist()
      });

      it("does not show a reshare_action link if the original post has been deleted", function(){
        this.post.set({post_type : "Reshare", root : null})
        this.view.render();
        expect(this.view.$("a.reshare")).not.toExist()
      })
    })

    context("when the post is not public", function(){
      beforeEach(function(){
        this.post.attributes.public = false;
        this.post.attributes.root = {author : {name : "susan"}};
        this.view.render();
      })

      it("shows 'Limited'", function(){
        expect($(this.view.el).html()).toContain(Evergreen.I18n.t('stream.limited'))
      })

      it("does not show a reshare_action link", function(){
        expect(this.view.$("a.reshare")).not.toExist()
      });
    })

    context("when the current user owns the post", function(){
      beforeEach(function(){
        this.post.attributes.author = app.currentUser;
        this.view.render();
      })

      it("does not display a reshare_action link", function(){
        this.post.attributes.public = false
        this.view.render();
        expect(this.view.$("a.reshare")).not.toExist()
      })
    })
  })

  describe("resharePost", function(){
    beforeEach(function(){
      this.post.attributes.public = true
      this.post.attributes.root = {author : {name : "susan"}};
      this.view.render();
    })

    it("displays a confirmation dialog", function(){
      spyOn(window, "confirm")
      this.view.$("a.reshare").first().click();
      expect(window.confirm).toHaveBeenCalled();
    })

    it("reshares the model", function(){
      spyOn(window, "confirm").andReturn(true);
      spyOn(this.view.model.reshare(), "save").andReturn(new $.Deferred)
      this.view.$("a.reshare").first().click();
      expect(this.view.model.reshare().save).toHaveBeenCalled();
    })
  })
})

