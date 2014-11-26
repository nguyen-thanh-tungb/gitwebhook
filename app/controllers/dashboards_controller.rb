class DashboardsController < ApplicationController
  require "rubygems"
  require "google/api_client"
  require "google_drive"
  before_action :set_dashboard, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :except => :create

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = Dashboard.all
    client = Google::APIClient.new
    auth = client.authorization
    auth.client_id = "869508551628-dsc1d1slh69481ffitnalsgocd5avq4p.apps.googleusercontent.com"
    auth.client_secret = "OiLs9XrB6XkZZIe1fwvBkASC"
    auth.scope =
      "https://www.googleapis.com/auth/drive " +
      "https://spreadsheets.google.com/feeds/"
    auth.redirect_uri = "http://4a97b635.ngrok.com"
    @url = auth.authorization_uri

    if params[:code].present?
      auth.code = params[:code]
      auth.fetch_access_token!
      access_token = auth.access_token
      @token = access_token
    end
    binding.pry
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
  end

  # GET /dashboards/new
  def new
    @dashboard = Dashboard.new
  end

  # GET /dashboards/1/edit
  def edit
  end

  # POST /dashboards
  # POST /dashboards.json
  def create
    @token = "ya29.zwDH9WBHqx_tF7d6mwLn-uHqpMpbKA99NLngh7WmAt4txwBVOcJb-3XfZrBhhDxavjPjRQTHh1YDOQ"
    if @token.present?
      session = GoogleDrive.login_with_oauth(@token)
      ws = session.spreadsheet_by_key("1RgNHzUZ43TW7PiGTmwptOQgZN_FCUJHuY8ROKYwltJ0").worksheets[0]
      if (params["action"] == "create" && params["issue"].present?)
        if params["issue"]["assignee"].present?
          assignee = params["issue"]["assignee"]["login"]
        end
        if params["issue"].present?
          created_at = params["issue"]["created_at"]
        end
        issue_id = params["issue"]["id"]
        issue_content = params["issue"]["body"]
        new_row_index = ws.num_rows+1
        ws[new_row_index, 1] =  issue_id
        ws[new_row_index, 3] =  issue_content
        ws[new_row_index, 4] =  assignee
        ws[new_row_index, 5] =  created_at
        ws.save
      end
      ws.reload
    end
    respond_to do |format|
      format.html { render "index" }
    end
  end

  # PATCH/PUT /dashboards/1
  # PATCH/PUT /dashboards/1.json
  def update
    respond_to do |format|
      if @dashboard.update(dashboard_params)
        format.html { redirect_to @dashboard, notice: 'Dashboard was successfully updated.' }
        format.json { render :show, status: :ok, location: @dashboard }
      else
        format.html { render :edit }
        format.json { render json: @dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dashboards/1
  # DELETE /dashboards/1.json
  def destroy
    @dashboard.destroy
    respond_to do |format|
      format.html { redirect_to dashboards_url, notice: 'Dashboard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dashboard
      @dashboard = Dashboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dashboard_params
      params.require(:dashboard).permit(:data)
    end
end
