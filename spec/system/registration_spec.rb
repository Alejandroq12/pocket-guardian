require 'rails_helper'

RSpec.describe 'UserRegistration', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'allows a new user to register' do
    visit new_user_registration_path

    fill_in 'Full name', with: 'Test User'
    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password (6 characters minimum).', with: 'password'
    fill_in 'Password confirmation', with: 'password'

    # Select the first profile image option available
    first('.signup_form__radio--button').click

    click_button 'Sign up'

    expect(page).to have_text('A message with a confirmation link has been sent to your email address.')
    expect(User.last.email).to eq('newuser@example.com')
  end
end
