app.views.TagFollowingAction = app.views.Base.extend({

  templateName: "tag_following_action",

  events : {
    "mouseenter .button.red_on_hover": "mouseIn",
    "mouseleave .button.red_on_hover": "mouseOut",
    "click .button": "tagAction"
  },

  initialize : function(options){
    this.tagText = options.tagText;
    this.getTagFollowing();
    app.tagFollowings.bind("remove add", this.getTagFollowing, this);
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      tag_is_followed : this.tag_is_followed(),
      followString : this.followString()
    })
  },

  followString : function() {
    if(this.tag_is_followed()) {
      return Evergreen.I18n.t("stream.tags.following", {"tag" : this.model.attributes.name});
    } else {
      return Evergreen.I18n.t("stream.tags.follow", {"tag" : this.model.attributes.name});
    }
  },

  tag_is_followed : function() {
    return !this.model.isNew();
  },

  getTagFollowing : function(tagFollowing) {
    this.model = app.tagFollowings.where({"name":this.tagText})[0] ||
        new app.models.TagFollowing({"name":this.tagText});
    this.model.bind("change", this.render, this);
    this.render();
  },

  mouseIn : function(){
    this.$("input").removeClass("in_aspects");
    this.$("input").val( Evergreen.I18n.t('stream.tags.stop_following', {tag: this.model.attributes.name} ) );
  },

  mouseOut : function() {
    this.$("input").addClass("in_aspects");
    this.$("input").val( Evergreen.I18n.t('stream.tags.following', {"tag" : this.model.attributes.name} ) );
  },

  tagAction : function(evt){
    if(evt){ evt.preventDefault(); }

    if(this.tag_is_followed()) {
      this.model.destroy();
    } else {
      app.tagFollowings.create(this.model);
    }
  }
});