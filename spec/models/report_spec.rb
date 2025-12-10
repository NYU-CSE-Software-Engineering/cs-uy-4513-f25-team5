require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'associations' do
    it 'has a reporter association to User' do
      assoc = Report.reflect_on_association(:reporter)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.class_name).to eq('User')
    end

    it 'has a reported_user association to User' do
      assoc = Report.reflect_on_association(:reported_user)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.class_name).to eq('User')
    end
  end

  describe 'validations' do
    let(:reporter) { create(:user) }
    let(:reported) { create(:user) }

    it 'is invalid without a report_type' do
      report = build(:report, report_type: nil, reporter: reporter, reported_username: reported.email)
      expect(report).not_to be_valid
      expect(report.errors[:report_type]).to include("can't be blank")
    end

    it 'is invalid without a reporter' do
      report = build(:report, reporter: nil, reported_username: reported.email, report_type: 'Harassment')
      expect(report).not_to be_valid
      expect(report.errors[:reporter]).to include("can't be blank")
    end

    it 'is invalid without a reported_username' do
      report = build(:report, reported_username: nil, reporter: reporter, report_type: 'Harassment')
      expect(report).not_to be_valid
      expect(report.errors[:reported_username]).to include("can't be blank")
    end

  #   it 'is invalid if reported_username does not exist' do
  #     report = build(:report, reported_username: 'nonexistent@example.com', reporter: reporter, report_type: 'Harassment')
  #     expect(report).not_to be_valid
  #     expect(report.errors[:reported_username]).to include("User does not exist")
  #   end
  end

  describe 'report_type validation' do
    let(:reporter) { create(:user) }
    let(:reported) { create(:user) }

    it 'allows valid report types' do
      valid_types = ['Harassment', 'Spam', 'Inappropriate Content', 'Other']
      valid_types.each do |type|
        report = build(:report, report_type: type, reporter: reporter, reported_username: reported.email)
        expect(report).to be_valid
      end
    end

    it 'rejects invalid report types' do
      report = build(:report, report_type: 'InvalidType', reporter: reporter, reported_username: reported.email)
      expect(report).not_to be_valid
    end
  end
end