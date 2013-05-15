class TuftsDcDetailed < ActiveFedora::NokogiriDatastream

  # 2012-01-23 decided to make everything searchable here and handle facetable in the to_solr methods of the
  # models

  set_terminology do |t|
    t.root(path: "dc", "xmlns" => "http://purl.org/dc/elements/1.1/",
           "xmlns:dca_dc" => "http://nils.lib.tufts.edu/dca_dc/",
           "xmlns:dcadec" => "http://nils.lib.tufts.edu/dcadesc/",
           "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
           "xmlns:dcterms" => "http://purl.org/d/terms/",
           "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    t.title(:index_as => :stored_searchable, :label => "Title")
    t.creator(:index_as => :stored_searchable, :label => "Creator")
    t.source(:index_as => :stored_searchable, :label => "Source")
    t.description(:index_as => :stored_searchable, :label => "Description")
    t.date_created(:path => "date.created", :index_as => :displayable, :label => "Date Created")
    t.date_available(:path => "available", :index_as => :stored_searchable, :label => "Date Available")
    t.date_issued(:path => "issued", :index_as => :stored_searchable, :label => "Date Issued")
    t.identifier(:path => "identifier", :index_as => :stored_searchable, :label => "PID / Handle")
    t.rights(:path => "rights", :index_as => :stored_searchable, :label => "Rights")
    t.bibliographic_citation(:namespace_prefix => "dcterms", :path => "bibliographicCitation", :index_as => :stored_searchable, :label => "Bibliographic Citation")
    t.publisher(:path => "publisher", :index_as => :stored_searchable, :label => "Publisher")
    t.type(:path => "type", :index_as => :stored_searchable, :label => "Type")
    t.format(:path => "format", :index_as => :stored_searchable, :label => "Format")
    t.extent(:path => "extent", :index_as => :stored_searchable, :label => "Extent")
    t.persname(:namespace_prefix => "dcadesc", :path => "persname", :index_as => :stored_searchable, :label => "Person Name")
    t.corpname(:namespace_prefix => "dcadesc", :path => "corpname", :index_as => :stored_searchable, :label => "Corporate Name")
    t.geogname(:namespace_prefix => "dcadesc", :path => "geogname", :index_as => :stored_searchable, :label => "Geographic Name")
    t.genre(:namespace_prefix => "dcadesc", :index_as => :stored_searchable, :label => "DCA Genre")
    t.subject(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Subject")
    t.funder(:namespace_prefix => "dcadesc", :index_as => :stored_searchable, :label => "Funder")
    t.temporal(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Temporal")
    t.resolution(:namespace_prefix => "dcatech", :index_as => :stored_searchable, :label => "Resolution")
    t.bit_depth(:namespace_prefix => "dcatech", :path => "bitdepth", :index_as => :stored_searchable, :label => "Bit Depth")
    t.color_space(:namespace_prefix => "dcatech", :path => "colorspace", :index_as => :stored_searchable, :label => "Color Space")
    t.file_size(:namespace_prefix => "dcatech", :path => "fileSize", :index_as => :stored_searchable, :label => "File Size")
    t.alternative(:namespace_prefix => "dcterms", :path => "alternative", :index_as => :stored_searchable, :label => "Alternative Title")
    t.contributor(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Contributor")
    t.abstract(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Abstract")
    t.toc(:namespace_prefix => "dcterms", :path => "tableOfContents", :index_as => :stored_searchable, :label => "Table of Contents")
    t.date(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Date")
    t.date_copyrighted(:namespace_prefix => "dcterms", :path => "dateCopyrighted", :index_as => :stored_searchable, :label => "Date Copyrighted")
    t.date_submitted(:namespace_prefix => "dcterms", :path => "dateSubmitted", :index_as => :stored_searchable, :label => "Date Submitted")
    t.date_accepted(:namespace_prefix => "dcterms", :path => "dateAccepted", :index_as => :stored_searchable, :label => "Date Accepted")
    t.date_modified(:namespace_prefix => "dcterms", :path => "modified", :index_as => :stored_searchable, :label => "Date Modified")
    t.language(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Language")
    t.medium(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Medium")
    t.provenance(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Provenance")
    t.access_rights(:namespace_prefix => "dcterms", :path => "accessRights", :index_as => :stored_searchable, :label => "Access Rights")
    t.rights_holder(:namespace_prefix => "dcterms", :path => "rightsHolder", :index_as => :stored_searchable, :label => "Rights Holder")
    t.license(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "License")
    t.replaces(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Replaces")
    t.isReplacedBy(:namespace_prefix => "dcterms", :path => "isReplacedBy", :index_as => :stored_searchable, :label => "Is Replaced By")
    t.hasFormat(:namespace_prefix => "dcterms", :path => "hasFormat", :index_as => :stored_searchable, :label => "Has Format")
    t.isFormatOf(:namespace_prefix => "dcterms", :path => "isFormatOf", :index_as => :stored_searchable, :label => "Is Format Of")
    t.hasPart(:namespace_prefix => "dcterms", :path => "hasPart", :index_as => :stored_searchable, :label => "Has Part")
    t.isPartOf(:namespace_prefix => "dcterms", :path => "isPartOf", :index_as => :stored_searchable, :label => "Is Part Of")
    t.accruralPolicy(:namespace_prefix => "dcterms", :path => "accrualPolicy", :index_as => :stored_searchable, :label => "Accrual Policy")
    t.audience(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Audience")
    t.references(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "References")
    t.specialCoverage(:namespace_prefix => "dcterms", :path => "specialCoverage", :index_as => :stored_searchable, :label => "Special Coverage")


  end

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  # I thought my confusion here was in what OM was doing but its actually a lack of knowledge
  # in how Nokogiri works.
  # see here for more details:
  # http://nokogiri.org/Nokogiri/XML/Builder.html
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.dc(:version => "0.1", :xmlns => "http://www.fedora.info/definitions/",
             "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
             "xmlns:dcadesc" => "http://nils.lib.tufts.edu/dcadesc/",
             "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
             "xmlns:dcterms" => "http://purl.org/d/terms/",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink") {
        xml['dc'].title
        xml['dc'].creator
        xml['dc'].source
        xml['dc'].description
        xml['dc'].send(:"date.created")
        xml['dc'].send(:"date.available")
        xml['dc'].send(:"date.issued")
        xml['dc'].identifier
        xml['dc'].rights
        xml['dc'].bibliographicCitation
        xml['dc'].publisher
        xml['dc'].type
        xml['dc'].format
        xml['dc'].extent
        xml['dcadesc'].persname
        xml['dcadesc'].corpname
        xml['dcadesc'].geogname
        xml['dcterms'].subject
        xml['dcadesc'].funder
        xml['dcterms'].temporal
        xml['dcatech'].resolution
        xml['dcadesc'].bitdepth
        xml['dcadesc'].colorspace
        xml['dcadesc'].filesize
        xml['dcterms'].alternative
        xml['dcterms'].contributor
        xml['dcterms'].abstract
        xml['dcterms'].toc
        xml['dcterms'].date
        xml['dcterms'].dateCopyrighted
        xml['dcterms'].dateSubmitted
        xml['dcterms'].dateAccepted
        xml['dcterms'].dateModified
        xml['dcterms'].language
        xml['dcterms'].medium
        xml['dcterms'].provenance
        xml['dcterms'].accessRights
        xml['dcterms'].rightsHolder
        xml['dcterms'].license
        xml['dcterms'].replaces
        xml['dcterms'].isReplacedBy
        xml['dcterms'].hasFormat
        xml['dcterms'].isFormatOf
        xml['dcterms'].hasPart
        xml['dcterms'].isPartOf
        xml['dcterms'].accruralPolicy
        xml['dcterms'].audience
        xml['dcterms'].references
        xml['dcterms'].specialCoverage

      }
    end

    #Feels hacky but I can't come up with another way to ensure the namespace
    #gets set correctly here.
    #builder.doc.root.name="dca_dc:dc"
    #The funny thing is that while the above makes the xml *look* like our XML
    #Fedora itself complains that the dca_dc is not bound and the XML is not well
    #formed makes me wonder if we've been generally wrong on this all along.

    return builder.doc
  end
  def to_solr(solr_doc = Hash.new) # :nodoc:
    return solr_doc
  end
end
