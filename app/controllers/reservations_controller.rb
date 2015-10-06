class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :destroy]

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = current_user.reservations
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    redirect_to :root unless @reservation.requester == current_user
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.requester = current_user
    if params[:reservation][:nook_id]
      @nook = Nook.find(params[:reservation][:nook_id])
      @reservation.nook = @nook
    end

    respond_to do |format|
      if @reservation.save
        format.html {
          flash[:notice] = t('reservations.submitted')
          if request.xhr?
            render text: nooks_url
          else
            redirect_to nooks_path
          end
        }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    if @reservation.requester == current_user
      @reservation.destroy
      respond_to do |format|
        format.html { redirect_to reservations_url, notice: 'Reservation was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:name, :start, :end, :description,
                                          :url, :stream_url, :notes)
    end
end
