class TuftsBase < ActiveFedora::Base
  include Tufts::ModelMethods
  include Hydra::ModelMixins::RightsMetadata
  include AttachedFiles
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  belongs_to :ead, :property => :has_description

  # Tufts specific needed metadata streams
  has_metadata "DCA-META", type: TuftsDcaMeta
  has_metadata "DCA-ADMIN", type: DcaAdmin

  attr_accessor :push_production

  before_save do
    self.edited_at = DateTime.now
    self.admin.published_at = edited_at if push_production
  end

  #MK 2011-04-13 - Are we really going to need to access FILE-META from FILE-META.  I'm guessing
  # not.
  has_metadata :name => "FILE-META", :type => TuftsFileMeta


  validates :title, :presence => true
  validates :displays, :inclusion => { :in => %w(dl tisch aah perseus elections dark), :if => :displays}
  
  delegate_to "DCA-META", [:title, :creator, :source2, :description, :date_created, :date_available, 
                           :date_issued, :identifier, :rights, :bibliographic_citation, :publisher,
                           :type2, :format2, :extent, :persname, :corpname, :geogname, :genre,
                           :subject, :funder, :temporal, :resolution, :bitdepth, :colorspace, 
                           :filesize]
  delegate_to "DCA-ADMIN", [:published_at, :edited_at, :displays], unique: true
  delegate_to "DCA-ADMIN", [:steward, :name, :comment, :retentionPeriod, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note]


  def datastreams= (ds_data)
    ds_data.each do |dsid, val|
      next unless val.present?
      ds = datastreams[dsid]
      if ds.external?
        ds.dsLocation = val
      end
    end
  end

  # The list of all fields on this object that can be edited.
  # this governs the values that will be accepted from the form submission
  def terms_for_editing
    terms_for_display 
  end

  def terms_for_display
    descMetadata_display_fields + admin_display_fields
  end

  # The list of fields to edit from the DCA_META datastream
  def descMetadata_display_fields
    descMetadata.class.terminology.terms.keys - [:root]
  end

  # The list of fields to edit from the DCA_ADMIN datastream
  def admin_display_fields
    admin.class.terminology.terms.keys  - [:admin, :published_at, :edited_at]
  end

  # a more idiomatic name for the DCA-META datastream
  def descMetadata
    self.DCA_META
  end

  # a more idiomatic name for the DCA-ADMIN datastream
  def admin
    self.DCA_ADMIN
  end

  # return a list of external datastreams
  def external_datastreams
    datastreams.select { |name, ds| ds.external? }
  end

  # Test to see if the given field is required
  # @param [Symbol] key a field
  # @return [Boolean] is it required or not
  def required?(key)
    self.class.validators_on(key).any?{|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end

  # Has this record been published yet?
  def published?
    published_at == edited_at
  end

  # Publish the record to the production fedora server
  def push_to_production!
    self.push_production = true
    if save
      # Now copy to prod
      # Rubydora::FedoraInvalidRequest
      foxml = self.inner_object.repository.export(pid: pid, context: 'archive')
      # You can't ingest to a pid that already exists, so try to purge it first
      production_fedora_connection.purge_object(pid: pid) rescue RestClient::ResourceNotFound
      production_fedora_connection.ingest(file: foxml)
    else
      # couldn't save
      raise "Unable to push to production"
    end
  end

  def production_fedora_connection
    @prod_repo ||= Rubydora.connect(ActiveFedora.data_production_credentials)
  end


  def to_solr(solr_doc=Hash.new, opts={})
    solr_doc = super
    models = self.relationships(:has_model)
    unless models.include?("info:fedora/cm:Text.RCR") || models.include?("info:fedora/afmodel:TuftsRCR")
      create_facets solr_doc
    end

    index_sort_fields solr_doc
    index_fulltext solr_doc

    return solr_doc
  end
end


