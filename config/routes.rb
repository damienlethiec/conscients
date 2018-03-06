# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:locale)', locale: /fr/ do
    root to: 'pages#home'
  end
end
