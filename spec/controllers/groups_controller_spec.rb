require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group, user:) } # Ensure group belongs to user

  before do
    sign_in user
  end

  describe 'GET #index' do
    it "assigns user's groups to @groups" do
      get :index
      expect(assigns(:groups)).to eq([group])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested group to @group' do
      get :show, params: { user_id: user.id, id: group.id }
      expect(assigns(:group)).to eq(group)
    end
  end

  describe 'GET #new' do
    it 'assigns a new Group to @group' do
      get :new, params: { user_id: user.id }
      expect(assigns(:group)).to be_a_new(Group)
    end
  end
end
