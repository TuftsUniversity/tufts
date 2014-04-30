require 'spec_helper'

describe TuftsBase do

  it 'knows which fields to display for admin metadata' do
    subject.admin_display_fields.should == [:steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note, :createdby, :creatordept]
  end

  it 'batch_id is not editable by users' do
    subject.terms_for_editing.include?(:batch_id).should be_false
  end

  describe 'required fields:' do
    it 'requires a title' do
      subject.required?(:title).should be_true
    end

    it 'requires displays' do
      subject.required?(:displays).should be_true
    end
  end

  describe 'OAI ID' do

    it "assigns an OAI ID to an object with a 'dl' display" do
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.save!
      oai_id(obj).should == "oai:#{obj.pid}"
    end

    it "does not assign OAI ID to an object with a non-'dl' display" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!
      rels_ext = Nokogiri::XML(obj.rels_ext.content)
      namespace = "http://www.openarchives.org/OAI/2.0/"
      prefix = rels_ext.namespaces.key(namespace).should be_nil
    end

    it 'does not change an existing OAI ID when you save the object' do
      existing_oai_id = 'oai:old_id'
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.object_relations.add(:oai_item_id, existing_oai_id, true)
      obj.save!
      oai_id(obj).should == existing_oai_id
    end

    it "does not remove the OAI ID if a 'dl' object is changed to a non-'dl' object" do
      obj = TuftsBase.new(title: 'foo', displays: ['dl'])
      obj.save!

      obj.displays = ['tisch']
      obj.save!
      oai_id(obj).should == "oai:#{obj.pid}"
    end

    it "generates an OAI ID if an existing object is changed to display portal 'dl'" do
      obj = TuftsBase.new(title: 'foo', displays: ['tisch'])
      obj.save!

      obj.displays = ['dl']
      obj.save!
      oai_id(obj).should == "oai:#{obj.pid}"
    end
  end

  def oai_id(obj)
    rels_ext = Nokogiri::XML(obj.rels_ext.content)
    namespace = "http://www.openarchives.org/OAI/2.0/"
    prefix = rels_ext.namespaces.key(namespace).match(/xmlns:(.*)/)[1]
    rels_ext.xpath("//rdf:Description/#{prefix}:itemID").text
  end


  describe '.stored_collection_id' do
    describe 'with an existing collection' do
      it "reads the collection_id" do
        m = TuftsBase.new(collection: TuftsEAD.new(pid: 'orig'))
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe 'with an existing ead' do
      it "reads the ead_id" do
        m = TuftsBase.new(ead: TuftsEAD.new(pid: 'orig'))
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe "with a specified collection that doesn't exist yet" do
      it "reads the collection_id" do
        m = TuftsBase.new
        m.add_relationship(m.object_relations.uri_predicate(:is_member_of), 'info:fedora/orig')
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
    describe "with a specified ead that doesn't exist yet" do
      it "reads the ead_id" do
        m = TuftsBase.new
        m.add_relationship(m.object_relations.uri_predicate(:has_description), 'info:fedora/orig')
        expect(m.stored_collection_id).to eq 'orig'
      end
    end
  end

  describe '.stored_collection_id=' do
    subject do
      c = TuftsEAD.create(title: 'collection', displays: ['dl'])
      m = TuftsBase.new(title: 't', collection: c, displays: ['dl'])
      m.save! # savign to make it write rels_ext.content
      expect(m.rels_ext.to_rels_ext).to match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
      m
    end
    it "updates the rels_ext.content" do
      c = subject.collection
      subject.stored_collection_id = 'changed'
      subject.save! # saving to make sure no other hooks overwrite the rels_ext.content
      expect(subject.rels_ext.content).to match(/hasDescription.+resource="info:fedora\/changed"/)
      expect(subject.rels_ext.content).to match(/isMemberOf.+resource="info:fedora\/changed"/)
      expect(subject.rels_ext.content).to_not match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
    end
    
    it "deletes a relationship" do
      c = subject.collection
      subject.stored_collection_id = nil
      subject.save! # saving to make sure no other hooks overwrite the rels_ext.content
      expect(subject.rels_ext.content).to_not match(/isMemberOf.+resource="info:fedora\/#{c.pid}"/)
    end

    it "lets you create a category after creating the relationship" do
      pid = 'tufts:deferred'

      # make sure this doesn't exist because we don't truncate our db before running the tests
      TuftsEAD.find(pid).destroy if TuftsEAD.exists?(pid)

      m = TuftsBase.new(title: 't', displays: ['dl'])
      m.stored_collection_id = pid
      m.save!
      expect(m.collection).to be_nil
      c = TuftsEAD.create(title: 'collection', pid: pid, displays: ['dl'])
      m.reload
      expect(m.collection).to eq c
    end
  end

  describe 'Batch operations' do
    it 'has a field for batch_id' do
      subject.batch_id = ['1', '2', '3']
      subject.batch_id.should == ['1', '2', '3']
    end
  end

  describe '#publish!' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      @obj = TuftsBase.new(title: 'My title', displays: ['dl'])
      @obj.save!

      prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      prod.should_receive(:purge_object).with(pid: @obj.pid)
      prod.should_receive(:ingest)
      @obj.stub(:production_fedora_connection) { prod }
    end

    after do
      @obj.delete if @obj
    end

    it 'adds an entry to the audit log' do
      @obj.publish!(user.id)
      @obj.reload
      @obj.audit_log.who.include?(user.user_key).should be_true
      @obj.audit_log.what.should == ['Pushed to production']
    end

    it 'publishes the record to the production fedora' do
      @obj.publish!
      @obj.reload
      @obj.published?.should be_true
    end
  end

  describe '.revert_to_production' do
    let(:user) { FactoryGirl.create(:user) }
    after do
      @model.delete if @model
    end

    context "record exists on prod and staging (normal case)" do
      before do
        @model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        @model.publish!(user.id)
        @model.title = "staging title"
        @model.save!
      end

      it 'replaces the record with the one in production' do
        TuftsBase.revert_to_production(@model.pid)
        expect(@model.reload.title).to eq "prod title"
      end

      it 'saves the object as published' do
        published_at = @model.published_at
        @model.published_at = 2.days.ago
        @model.save!
        TuftsBase.revert_to_production(@model.pid)
        @model.reload
        expect(@model.published?).to be_true
        # using greater than because published_at seems to be re-set instead of copied
        # when publish! is called. It is often off by one second.
        expect(@model.published_at).to be > (published_at - 1.hour)
      end
    end

    context "record exists on prod, but not on staging" do
      before do
        model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        model.publish!(user.id)
        @pid = model.pid
        model.delete
        TuftsBase.revert_to_production(@pid)
      end
      it 'copys the record from production' do
        expect(TuftsPdf.exists?(@pid)).to be_true
        expect(TuftsPdf.find(@pid).title).to eq "prod title"
      end
    end

    context "record doesn't exist on prod, exists on staging" do
      before do
        @model = FactoryGirl.create(:tufts_pdf, title: "prod title")
        @model.purge!
      end
      it 'raises an error' do
        expect{TuftsBase.revert_to_production(@model.pid)}.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end

  describe "#purge!" do
    subject { TuftsBase.create(title: 'some title') }
    before do
      TuftsPdf.connection_for_pid('tufts:1')
      @prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      allow(subject).to receive(:production_fedora_connection) { @prod }
    end
    it "hard deletes this pid on production" do
      expect(@prod).to receive(:purge_object).with(pid: subject.pid)
      subject.purge!
    end

    it "soft deletes this pid on staging" do
      subject.purge!
      expect(subject.state).to eq "D"
    end
  end

  describe 'audit log' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      subject.title = 'Some Title'
      subject.displays = ['dl']
      subject.working_user = user
    end
    after { subject.delete if subject.persisted? }

    it 'adds an entry if the content changes' do
      subject.stub(:content_will_update) { 'hello content' }
      subject.save!
      subject.audit_log.who.include?(user.user_key).should be_true
      subject.audit_log.what.include?('Content updated: hello content').should be_true
    end

    it 'adds an entry if the metadata changes' do
      subject.admin.stub(:changed?) { true }
      subject.save!
      subject.audit_log.who.include?(user.user_key).should be_true
      messages = subject.audit_log.what.select {|x| x.match(/Metadata updated/)}
      messages.any?{|msg| msg.match(/DCA-ADMIN/)}.should be_true
    end
  end

end
