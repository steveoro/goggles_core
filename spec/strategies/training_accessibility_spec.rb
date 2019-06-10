# frozen_string_literal: true

require 'rails_helper'

describe TrainingAccessibility, type: :strategy, tag: :user do
  before :each do
    @user = create(:user)
    @non_shared_fixture = create(:training)
    @owned_fixture = create(:training, user: @user)
    @shared_fixture = create(:training)
    @shared_fixture.user.invite(@user, true, true, true)   # he wants to share everything
    @user.approve(@shared_fixture.user, true, true, true)  # the current user approves
  end

  context '[any user]' do # (no admin override)
    subject { TrainingAccessibility.new(@user, @non_shared_fixture, false) }

    [:is_owned, :is_visible].each do |method_name|
      it "responds to ##{method_name}" do
        expect(subject).to respond_to(method_name)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[any logged-in user, w/o shared or owned content]' do
    subject { TrainingAccessibility.new(@user, @non_shared_fixture, false) }

    describe '#is_owned()' do
      it 'is false' do
        expect(subject.is_owned).to be false
      end
    end
    describe '#is_visible()' do
      it 'is true' do
        expect(subject.is_visible).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[any logged-in user, w/ owned content]' do
    subject { TrainingAccessibility.new(@user, @owned_fixture, false) }

    describe '#is_owned()' do
      it 'is true' do
        expect(subject.is_owned).to be true
      end
    end
    describe '#is_visible()' do
      it 'is true' do
        expect(subject.is_visible).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[any logged-in user, w/ shared content]' do
    subject { TrainingAccessibility.new(@user, @shared_fixture, false) }

    describe '#is_owned()' do
      it 'is false' do
        expect(subject.is_owned).to be false
      end
    end
    describe '#is_visible()' do
      it 'is true' do
        expect(subject.is_visible).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
