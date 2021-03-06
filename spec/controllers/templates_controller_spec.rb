require 'spec_helper'

describe TemplatesController do
  context "when not signed in" do
    it 'redirects to sign in' do
      get :index
      expect(response).to redirect_to '/users/sign_in'
    end
  end

  context "when signed in" do
    before { sign_in user }

    describe 'as a non-admin user' do
      let(:user) { create(:user) }

      it 'redirects to contributions' do
        get :index
        expect(response).to redirect_to(contributions_path)
      end

    end

    describe 'as an admin user' do
      let(:user) { create(:admin) }

      context 'with some objects' do
        before do
          TuftsTemplate.destroy_all
          create(:tufts_template)
          create(:tufts_template)
          create(:tufts_pdf)
          create(:tufts_audio)
        end

        it 'returns only templates' do
          get :index
          expect(assigns[:document_list].count).to eq 2
        end
      end

      describe "create" do
        let(:hydra_editor) { HydraEditor::Engine.routes.url_helpers }
        it "creates one" do
          expect {
            post :create
          }.to change { TuftsTemplate.count }.by(1)
          expect(response).to redirect_to(hydra_editor.edit_record_path(assigns[:template]))
        end
      end

      describe "destroy" do
        let(:template) { create :tufts_template, template_name: 'Seamus' }

        it "removes one" do
          expect {
            delete :destroy, id: template
          }.to change { TuftsTemplate.exists?(template.pid) }.from(true).to(false)
          expect(flash[:notice]).to eq "\"Seamus\" has been purged"
          expect(response).to redirect_to templates_path
        end
      end
    end
  end
end
