require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe AccountsController, type: :controller do
  let(:user) {}

  before do
    sign_in user if user
  end

  # This should return the minimal set of attributes required to create a valid
  # Account. As you add validations to Account, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { name: 'x' }
  end

  let(:valid_fcrepo_endpoint_attributes) do
    { url: 'http://127.0.0.1:8984/go',
      base_path: '/dev' }
  end

  let(:invalid_attributes) do
    { tenant: 'missing-cname', cname: '' }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AccountsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context 'as an anonymous user' do
    describe "GET #new" do
      it "assigns a new account as @account" do
        get :new, {}, valid_session
        expect(assigns(:account)).to be_a_new(Account)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        before do
          allow_any_instance_of(CreateAccount).to receive(:create_external_resources)
        end

        it "creates a new Account" do
          expect do
            post :create, { account: valid_attributes }, valid_session
          end.to change(Account, :count).by(1)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved account as @account" do
          post :create, { account: invalid_attributes }, valid_session
          expect(assigns(:account)).to be_a_new(Account)
        end

        it "re-renders the 'new' template" do
          post :create, { account: invalid_attributes }, valid_session
          expect(response).to render_template("new")
        end
      end
    end
  end

  context 'as an admin of a site' do
    let(:user) { FactoryGirl.create(:user).tap { |u| u.add_role(:admin, Site.instance) } }
    let(:account) { FactoryGirl.create(:account) }

    before do
      Site.update(account: account)
    end

    describe "GET #show" do
      it "assigns the requested account as @account" do
        get :show, { id: account.to_param }, valid_session
        expect(assigns(:account)).to eq(account)
      end
    end

    describe "GET #edit" do
      it "assigns the requested account as @account" do
        get :edit, { id: account.to_param }, valid_session
        expect(assigns(:account)).to eq(account)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) do
          { cname: 'new.example.com',
            fcrepo_endpoint_attributes: valid_fcrepo_endpoint_attributes }
        end

        it "updates the requested account" do
          put :update, { id: account.to_param, account: new_attributes }, valid_session
          account.reload
          expect(account.cname).to eq 'new.example.com'
          expect(account.fcrepo_endpoint.url).to eq 'http://127.0.0.1:8984/go'
          expect(response).to redirect_to(account)
        end

        it "assigns the requested account as @account" do
          put :update, { id: account.to_param, account: valid_attributes }, valid_session
          expect(assigns(:account)).to eq(account)
        end
      end

      context "with invalid params" do
        it "assigns the account as @account" do
          put :update, { id: account.to_param, account: invalid_attributes }, valid_session
          expect(assigns(:account)).to eq(account)
        end

        it "re-renders the 'edit' template" do
          put :update, { id: account.to_param, account: invalid_attributes }, valid_session
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "denies the request" do
        delete :destroy, { id: account.to_param }, valid_session
        expect(response).to have_http_status(401)
      end
    end

    context 'editing another tenants account' do
      let(:another_account) { FactoryGirl.create(:account) }

      describe "GET #show" do
        it "denies the request" do
          get :show, { id: another_account.to_param }, valid_session
          expect(response).to have_http_status(401)
        end
      end

      describe "GET #edit" do
        it "denies the request" do
          get :edit, { id: another_account.to_param }, valid_session
          expect(response).to have_http_status(401)
        end
      end

      describe "PUT #update" do
        it "denies the request" do
          put :update, { id: another_account.to_param, account: valid_attributes }, valid_session
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  context 'as a superadmin' do
    let(:user) { FactoryGirl.create(:superadmin) }
    let!(:account) { FactoryGirl.create(:account) }

    describe "GET #index" do
      it "assigns all accounts as @accounts" do
        get :index, {}, valid_session
        expect(assigns(:accounts)).to include account
      end
    end

    describe "GET #show" do
      it "assigns the requested account as @account" do
        get :show, { id: account.to_param }, valid_session
        expect(assigns(:account)).to eq(account)
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested account" do
        expect(CleanupAccountJob).to receive(:perform_now).with(account)

        delete :destroy, { id: account.to_param }, valid_session
      end

      it "redirects to the accounts list" do
        expect(CleanupAccountJob).to receive(:perform_now).with(account)
        delete :destroy, { id: account.to_param }, valid_session
        expect(response).to redirect_to(accounts_url)
      end
    end
  end

  describe 'account dependency switching' do
    let(:account) { FactoryGirl.create(:account) }

    before do
      Site.update(account: account)
      allow(controller).to receive(:current_account).and_return(account)
    end

    it 'switches account information' do
      expect(account).to receive(:switch!)
      get :show, { id: account.to_param }, valid_session
    end
  end
end
