class ScansController < ApplicationController
  def create
    scan = Current.organization.scans.create!(status: :pending)
    VisibilityScanJob.perform_later(Current.organization, scan)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path, notice: "Running a new AI visibility scan — this can take a moment." }
    end
  end
end
