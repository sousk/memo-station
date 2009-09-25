class CardsController < ApplicationController
  def index
    @cards = Card.paginate :page => params[:page]
  end
end
