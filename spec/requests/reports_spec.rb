require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'POST /reports' do
    before do
      post '/auth/login', params: { email: user.email, password: user.password }
    end

    context 'with valid parameters' do
      let(:valid_params) do
        {
          report: {
            reported_username: other_user.email,
            report_type: 'Harassment',
            description: 'Inappropriate behavior',
            reporter_id: user.id
          }
        }
      end

      it 'creates a new report' do
        expect {
          post reports_path, params: valid_params
        }.to change(Report, :count).by(1)
      end

      it 'returns a redirect status' do
        post reports_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          report: {
            reported_username: other_user.email,
            report_type: '',
            description: 'Missing type',
            reporter_id: user.id
          }
        }
      end

      it 'does not create a report' do
        expect {
          post reports_path, params: invalid_params
        }.not_to change(Report, :count)
      end
    end

    context 'with non-existent username' do
      let(:nonexistent_params) do
        {
          report: {
            reported_username: 'nonexistent@example.com',
            report_type: 'Harassment',
            description: 'User does not exist',
            reporter_id: user.id
          }
        }
      end

      it 'does not create a report' do
        expect {
          post reports_path, params: nonexistent_params
        }.not_to change(Report, :count)
      end
    end
  end
end