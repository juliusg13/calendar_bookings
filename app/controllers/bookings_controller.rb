class BookingsController < ApplicationController
  def create
    room = Room.find_by(params[:room_id])
    bookings_conflicting_with_passed_start_date = room.bookings.where(start: params[:start])
    bookings_conflicting_with_passed_end_date = room.bookings.where(end: params[:end])
    if bookings_conflicting_with_passed_start_date.any? or bookings_conflicting_with_passed_end_date.any?
      render json: { message: 'Booking conflicts with an existing booking' }, status: :unprocessable_entity
    else
      start_date = Date.parse(params[:start])
      end_date = Date.parse(params[:end])


      if verify_conflicts(room, start_date, end_date)
        booking = Booking.new(booking_params)
        booking.save

        render json: { message: 'Booking created.' }, status: :ok
      else
        render json: { message: 'Booking conflicts with an existing booking' }, status: :unprocessable_entity
      end
    end
  end

  private

  def verify_conflicts(room, start_date, end_date)
    room.bookings.each do |possibly_conflicting_booking|
      possibly_conflicting_start_date = possibly_conflicting_booking.start
      possibly_conflicting_end_date = possibly_conflicting_booking.end
      while(possibly_conflicting_start_date <= possibly_conflicting_end_date) do
        if possibly_conflicting_start_date >= start_date and possibly_conflicting_start_date <= end_date
          return false
        elseif possibly_conflicting_end_date >= start_date and possibly_conflicting_end_date <= end_date
          return false
        elseif possibly_conflicting_start_date <= start_date and possibly_conflicting_end_date >= end_date
          return false
        end
        possibly_conflicting_start_date += 1.day
      end
    end

  end

  def booking_params
    params.permit(:start, :end, :room_id)
  end
end
