class PlayingCardsController < ApplicationController
  before_action :set_playing_card, only: %i[ show edit update destroy ]

  # GET /playing_cards or /playing_cards.json
  def index
    @playing_cards = PlayingCard.all
  end

  # GET /playing_cards/1 or /playing_cards/1.json
  def show
  end

  # GET /playing_cards/new
  def new
    @playing_card = PlayingCard.new
  end

  # GET /playing_cards/1/edit
  def edit
  end

  # POST /playing_cards or /playing_cards.json
  def create
    @playing_card = PlayingCard.new(playing_card_params)

    respond_to do |format|
      if @playing_card.save
        format.html { redirect_to @playing_card, notice: "Playing card was successfully created." }
        format.json { render :show, status: :created, location: @playing_card }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @playing_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playing_cards/1 or /playing_cards/1.json
  def update
    respond_to do |format|
      if @playing_card.update(playing_card_params)
        format.html { redirect_to @playing_card, notice: "Playing card was successfully updated." }
        format.json { render :show, status: :ok, location: @playing_card }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @playing_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playing_cards/1 or /playing_cards/1.json
  def destroy
    @playing_card.destroy!

    respond_to do |format|
      format.html { redirect_to playing_cards_path, status: :see_other, notice: "Playing card was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playing_card
      @playing_card = PlayingCard.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def playing_card_params
      params.expect(playing_card: [ :session_id, :suit, :rank, :zone_name, :face_up, :orientation, :position, :image_url, :back_image_url ])
    end
end
