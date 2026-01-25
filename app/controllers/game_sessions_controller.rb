class GameSessionsController < ApplicationController
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :set_game_session, only: %i[ show edit update destroy
                                             join_as_player join_as_observer toggle_role leave ]

  # POST /game_sessions/:id/join_as_player
  def join_as_player
    session_user = @game_session.session_users.find_or_initialize_by(user: current_user)
    session_user.role = :player

    # Assign first unassigned player zone if not set
    if session_user.zone_name.blank?
      assigned_zones = @game_session.session_users.where.not(zone_name: nil).pluck(:zone_name)
      available_zones = PlayingCard::ZONES - ["Neutral"] - assigned_zones
      session_user.zone_name = available_zones.first
    end

    session_user.save!
    redirect_to @game_session, notice: "You joined the session."
  end

  # POST /game_sessions/:id/join_as_observer
  def join_as_observer
    session_user = @game_session.session_users.find_or_initialize_by(user: current_user)
    session_user.role = :observer
    session_user.zone_name = nil
    session_user.save!
    redirect_to @game_session, notice: "You joined the session."
    # redirect_back(fallback_location: project_path(@game_session.project), notice: "Joined as observer.")
  end

  # PATCH /game_sessions/:id/toggle_role
  def toggle_role
    session_user = @game_session.session_users.find_by(user: current_user)
    return redirect_back(fallback_location: project_path(@game_session.project), alert: "Not part of this session.") unless session_user

    session_user.update!(role: session_user.player? ? :observer : :player)
    notice = session_user.player? ? "You are now a player." : "You are now an observer."
    redirect_back(fallback_location: project_path(@game_session.project), notice: notice)
  end

  # DELETE /game_sessions/:id/leave
  def leave
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
    unless @game_session.users.exists?(current_user.id) ||
           @game_session.owner == current_user
      redirect_to projects_path, alert: "You are not part of this session."
    end
  end

  # GET /game_sessions/new
  def new
    @game_session = GameSession.new
  end

  # GET /game_sessions/1/edit
  def edit
  end

  # POST /game_sessions or /game_sessions.json
  def create
    @game_session = GameSession.new(game_session_params)
    @game_session.owner = current_user

    if @game_session.save
      SessionUser.create!(
        game_session: @game_session,
        user: current_user,
        role: :host,
      )

      redirect_to @game_session, notice: "Game session started."
    else
      redirect_back fallback_location: projects_path,
                    alert: @game_session.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /game_sessions/1 or /game_sessions/1.json
  def update
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
    params.expect(game_session: [:project_id, :name, :private])
  end
end
