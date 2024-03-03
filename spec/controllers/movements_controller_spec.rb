require 'rails_helper'

RSpec.describe MovementsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group, user:) }
  let(:movement) { create(:movement, author: user, group:) }

  before do
    sign_in user
  end

  describe 'GET #new' do
    it 'assigns a new Movement to @movement' do
      get :new, params: { group_id: group.id }
      expect(assigns(:movement)).to be_a_new(Movement)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new movement' do
        expect do
          post :create, params: { group_id: group.id, movement: { name: 'New Movement', amount: 100 } }
        end.to change(Movement, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new movement' do
        expect do
          post :create, params: { group_id: group.id, movement: { name: '', amount: nil } }
        end.not_to change(Movement, :count)
      end
    end
  end
end
