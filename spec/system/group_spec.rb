require 'rails_helper'

RSpec.describe 'GroupCreation', type: :system do
  let!(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  it 'allows a logged-in user to create a new group' do
    visit new_user_group_path(user_id: user.id)
    fill_in 'Group name', with: 'New Group'

    find("label[for='icon_education.svg']").click

    click_button 'Create group'

    expect(page).to have_text('Group was successfully created.')
    expect(Group.last.user).to eq(user)
  end
end
