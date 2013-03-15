require Rails.root.join("lib", "Evergreen", "markdownify_email")

Rails.application.config.markerb.renderer = Evergreen::Markdownify::Email