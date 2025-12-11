require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) do
    User.create!(
      email: 'profile@example.com',
      password: 'password123',
      display_name: 'Initial Name',
      bio: 'Initial bio'
    )
  end

  def log_in(user)
    post '/auth/login', params: { email: user.email, password: 'password123' }
  end

  describe 'GET /profile' do
    before { log_in(user) }

    it 'renders the profile page successfully' do
      get profile_path

      expect(response).to be_successful
      expect(response.body).to include('Initial Name')
    end
  end

  describe 'PATCH /profile' do
    let(:valid_params) do
      {
        user: {
          display_name: 'Updated Name',
          bio: 'Updated bio',
          budget: 1500,
          preferred_location: 'Brooklyn, NY',
          sleep_schedule: 'Early riser',
          pets: 'No pets',
          housing_status: 'Looking for roommate',
          contact_visibility: 'Friends only'
        }
      }
    end

    before { log_in(user) }

    it 'updates the profile with valid data' do
      patch profile_path, params: valid_params

      expect(response).to redirect_to(profile_path)
      follow_redirect!

      expect(response.body).to include('Profile updated successfully')
      user.reload
      expect(user.display_name).to eq('Updated Name')
      expect(user.bio).to eq('Updated bio')
    end

    it 'does not update the profile with invalid data' do
      patch profile_path, params: { user: valid_params[:user].merge(display_name: '', budget: -5) }

      expect(response).to have_http_status(:unprocessable_content)
      errors_html = CGI.unescapeHTML(response.body)
      expect(errors_html).to include("Display name can't be blank")
      expect(errors_html).to include('Budget must be greater than or equal to 0')
      user.reload
      expect(user.display_name).to eq('Initial Name')
    end

    it 'updates the avatar when a file is uploaded' do
      file = fixture_file_upload(
        Rails.root.join('features', 'screenshots', 'user_profile_management_1.png'),
        'image/png'
      )

      patch profile_path, params: valid_params.deep_merge(user: { avatar: file })

      expect(response).to redirect_to(profile_path)
      expect(user.reload.avatar).to be_present
      expect(user.avatar.filename).to eq('user_profile_management_1.png')
      expect(user.avatar.image_base64).to be_present
    end

    it 'replaces an existing avatar when a new file is uploaded' do
      user.create_avatar!(image_base64: 'old-data', filename: 'old.png')

      new_file = fixture_file_upload(
        Rails.root.join('features', 'screenshots', 'user_profile_management_1.png'),
        'image/png'
      )

      patch profile_path, params: valid_params.deep_merge(user: { avatar: new_file })

      expect(response).to redirect_to(profile_path)
      user.reload
      expect(user.avatar).to be_present
      expect(user.avatar.filename).to eq('user_profile_management_1.png')
      expect(user.avatar.image_base64).not_to eq('old-data')
    end

    it 'keeps the existing avatar when updating profile without a new upload' do
      user.create_avatar!(image_base64: 'existing', filename: 'existing.png')

      patch profile_path, params: valid_params

      expect(response).to redirect_to(profile_path)
      user.reload
      expect(user.avatar).to be_present
      expect(user.avatar.filename).to eq('existing.png')
      expect(user.avatar.image_base64).to eq('existing')
    end

    it 'removes the avatar when requested' do
      user.create_avatar!(image_base64: 'stub', filename: 'old.png')

      patch profile_path, params: { remove_avatar: '1' }

      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.avatar).to be_nil
    end
  end

  describe 'authentication requirements' do
    it 'requires a signed-in user before showing the profile' do
      get profile_path

      expect(response).to redirect_to('/auth/login')
    end

    it 'rejects profile updates without a valid session' do
      patch profile_path,
            params: { user: { display_name: 'Blocked', bio: 'N/A' } }

      expect(response).to redirect_to('/auth/login')
    end
  end
end
