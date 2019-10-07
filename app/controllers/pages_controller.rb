# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @categories = Category.in_order_home.displayable
    @blog_posts = if I18n.locale == :fr
                    BlogPost.published_fr.in_order.first(2)
                  else
                    BlogPost.published_en.in_order.first(2)
                  end
  end
end
