class ProblemObjectivesController < ApplicationController
  def index
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    # Must be a nested route
    render :json => ProblemObjective.synced_models(synced_date, params[:join_ids], nil, params[:where]).as_json
  end
end
