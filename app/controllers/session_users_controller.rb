class SessionUsersController < ApplicationController
  before_action :set_session_user, only: %i[ show edit update destroy ]

  # GET /session_users or /session_users.json
  def index
    @session_users = SessionUser.all
  end

  # GET /session_users/1 or /session_users/1.json
  def show
  end

  # GET /session_users/new
  def new
    @session_user = SessionUser.new
  end

  # GET /session_users/1/edit
  def edit
  end

  # POST /session_users or /session_users.json
  def create
    @session_user = SessionUser.new(session_user_params)

    respond_to do |format|
      if @session_user.save
        format.html { redirect_to @session_user, notice: "Session user was successfully created." }
        format.json { render :show, status: :created, location: @session_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /session_users/1 or /session_users/1.json
  def update
    respond_to do |format|
      if @session_user.update(session_user_params)
        format.html { redirect_to @session_user, notice: "Session user was successfully updated." }
        format.json { render :show, status: :ok, location: @session_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @session_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /session_users/1 or /session_users/1.json
  def destroy
    @session_user.destroy!

    respond_to do |format|
      format.html { redirect_to session_users_path, status: :see_other, notice: "Session user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session_user
      @session_user = SessionUser.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def session_user_params
      params.expect(session_user: [ :game_session_id, :user_id, :role ])
    end
end
