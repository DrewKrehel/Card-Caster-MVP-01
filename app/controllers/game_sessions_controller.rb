class GameSessionsController < ApplicationController
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :set_game_session, only: %i[ show edit update destroy
                                             join_as_player join_as_observer toggle_role leave ]
  before_action :set_breadcrumbs, only: %i[show edit]

  # POST /game_sessions/:id/join_as_player
  def join_as_player
    authorize @game_session

    session_user = @game_session.session_users.find_or_initialize_by(user: current_user)

    unless @game_session.player_slots_remaining?
      redirect_back fallback_location: project_path(@game_session.project),
                    alert: "This session already has the maximum number of players."
      return
    end
    # Assigning player role & zone
    session_user.role = :player
    session_user.zone_name ||= @game_session.next_available_player_zone

    session_user.save!
    redirect_to @game_session, notice: "You joined the session."
  end

  # POST /game_sessions/:id/join_as_observer
  def join_as_observer
    authorize @game_session

    # Guests do not create session records
    if current_user.nil?
      redirect_to @game_session, notice: "You are viewing as an observer."
      return
    end

    session_user = @game_session.session_users.find_or_initialize_by(user: current_user)
    session_user.update!(role: :observer, zone_name: nil)

    redirect_to @game_session, notice: "You joined the session."
  end

  # PATCH /game_sessions/:id/toggle_role
  def toggle_role
    authorize @game_session

    session_user = @game_session.session_users.find_by(user: current_user)
    return redirect_back(fallback_location: project_path(@game_session.project), alert: "Not part of this session.") unless session_user

    if session_user.observer?
      unless @game_session.player_slots_remaining?
        redirect_back fallback_location: project_path(@game_session.project),
                      alert: "No player slots available."
        return
      end

      zone = @game_session.next_available_player_zone

      session_user.update!(role: :player, zone_name: zone)
      notice = "You are now a player."
    else
      session_user.update!(role: :observer, zone_name: nil)
      notice = "You are now an observer."
    end

    redirect_back(fallback_location: project_path(@game_session.project), notice: notice)
  end

  # DELETE /game_sessions/:id/leave
  def leave
    authorize @game_session

    session_user = @game_session.session_users.find_by(user: current_user)

    if session_user.nil? || session_user.user == @game_session.owner
      redirect_to project_path(@game_session.project),
                  alert: session_user.nil? ?
                    "You are not part of this session." :
                    "Hosts cannot leave their own session."
      return
    end

    session_user.destroy!

    redirect_to project_path(@game_session.project),
                notice: "You left the session."
  end

  # GET /game_sessions or /game_sessions.json
  def index
    @game_sessions = GameSession.all
  end

  # GET /game_sessions/1 or /game_sessions/1.json
  def show
    authorize @game_session

    # Preload session_users with their users, indexed by zone
    @session_users_by_zone = @game_session.session_users
                                          .includes(:user)
                                          .index_by(&:zone_name)

    # Preload all cards, grouped by zone
    @cards_by_zone = @game_session.playing_cards
      .order(:position)
      .group_by(&:zone_name)

    # Get current user's session_user once
    @current_session_user = @game_session.session_users.find_by(user: current_user)
  end

  # GET /game_sessions/new
  def new
    @game_session = GameSession.new
  end

  # GET /game_sessions/1/edit
  def edit
    authorize @game_session
  end

  # POST /game_sessions or /game_sessions.json
  def create
    @game_session = GameSession.new(game_session_params)
    @game_session.owner = current_user

    if @game_session.save
      zone = @game_session.next_available_player_zone

      @game_session.session_users.create!(
        user: current_user,
        role: :host,
        zone_name: zone,
      )

      redirect_to @game_session, notice: "Game session started."
    else
      redirect_back fallback_location: projects_path,
                    alert: @game_session.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /game_sessions/1 or /game_sessions/1.json
  def update
    authorize @game_session

    respond_to do |format|
      if @game_session.update(game_session_params)
        format.html { redirect_to @game_session, notice: "Game session was successfully updated." }
        format.json { render :show, status: :ok, location: @game_session }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_sessions/1 or /game_sessions/1.json
  def destroy
    authorize @game_session

    project = @game_session.project
    @game_session.destroy!

    respond_to do |format|
      format.html { redirect_to project_path(project), status: :see_other, notice: "Game session was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game_session
    @game_session = GameSession.find(params.require(:id))
  end

  # Only allow a list of trusted parameters through.
  def game_session_params
    params.require(:game_session).permit(:project_id, :name, :private)
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { name: "Projects", url: projects_path },
      { name: @game_session.project.name, url: project_path(@game_session.project) },
    ]

    if action_name == "show"
      @breadcrumbs << { name: @game_session.name, url: nil }
    elsif action_name == "edit"
      @breadcrumbs << { name: @game_session.name, url: game_session_path(@game_session) }
      @breadcrumbs << { name: "Edit", url: nil }
    end
  end
end
