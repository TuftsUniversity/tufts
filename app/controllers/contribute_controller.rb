class ContributeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:home, :license, :redirect]

  def home
  end

  def redirect # normal users calling '/' should be redirected to ''/contribute'
    redirect_to action: 'home'
  end

  def license
  end

  def new
    # TODO: add can-can authorize here
    @deposit_type = DepositType.where(id: params[:deposit_type]).first
    @contribution = TuftsPdf.new

    # Redirect the user to the selection page is the deposit type is invalid or missing
    redirect_to action: 'home' if @deposit_type.nil?
  end

  def create
    # TODO: add can-can authorize here
    @contribution = TuftsPdf.create(params[:tufts_pdf])
    upload_attachment
    flash[:notice] = "Your file has been saved!"
    redirect_to contribute_path
  end

  def upload_attachment
    dsid = 'Archival.pdf'
    file = params[:deposit_attachment]

    warnings = []
    messages = []

    if @contribution.valid_type_for_datastream?(dsid, file.content_type)
      messages << "#{dsid} has been added"
    else
      warnings << "You provided a #{file.content_type} file, which is not a valid type for #{dsid}"
    end

    # Persist the object to Fedora, so that we have a valid object and pid before storing the uploaded file
    # TODO: figure out why mime type isn't getting saved correctly
    @contribution.store_archival_file(dsid, file)

    #end
  end

end
