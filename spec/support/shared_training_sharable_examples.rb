# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'TrainingSharable' do
  # Describes the requisites of the including class
  # and the outcome of the module inclusion.
  #
  context 'by including this concern' do
    it_behaves_like('(the existance of a class method)', [:visible_to_user])
    it_behaves_like('(the existance of a method)', [:user, :visible_to_user])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.visible_to_user()' do
    before(:each) do
      @subject_instance_2 = create(subject.class.name.underscore.to_sym)
      @subject_instance_3 = create(subject.class.name.underscore.to_sym, user: @subject_instance_2.user)
    end

    context 'with stored trainings, as a user with no available shared trainings' do
      it 'returns an empty list of rows' do
        result = subject.class.visible_to_user(create(:user))
        expect(result).not_to be_nil
        expect(result).to respond_to(:size)
        expect(result).to respond_to(:each)
        expect(result.size).to eq(0)
      end
    end

    context 'with stored trainings, as a user with shared trainings' do
      before(:each) do
        @subject_instance_2.user.invite(subject.user, true, true, true)   # he wants to share everything
        subject.user.approve(@subject_instance_2.user, true, true, true)  # the other one approves
      end

      it 'returns a non-empty list of rows' do
        result = subject.class.visible_to_user(subject.user)
        expect(result).not_to be_nil
        expect(!result.empty?).to be true
      end
      it 'returns a same.sized list of results for all the sharing friends' do
        result_1 = subject.class.visible_to_user(subject.user)
        result_2 = subject.class.visible_to_user(@subject_instance_2.user)
        expect(result_1).not_to be_nil
        expect(result_2).not_to be_nil
        expect(result_1.size).to eq(result_2.size)
      end
      it 'returns same-item lists for all the sharing friends' do
        result_1 = subject.class.visible_to_user(subject.user)
        result_2 = subject.class.visible_to_user(@subject_instance_2.user)
        result_1.each do |row|
          expect(result_2.include?(row)).to be true
        end
      end
      it 'returns only rows that are shared and visibile for both' do
        result = subject.class.visible_to_user(subject.user)
        result.each do |row|
          expect([subject.user_id, @subject_instance_2.user_id].include?(row.user_id)).to be true
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#visible_to_user' do
    before(:each) do
      @subject_instance_2 = create(subject.class.name.underscore.to_sym)
      @subject_instance_3 = create(subject.class.name.underscore.to_sym, user: @subject_instance_2.user)
    end

    context 'with stored trainings, as a user with no available shared trainings' do
      it 'returns false for a training created by another user' do
        result = subject.visible_to_user(create(:user))
        expect(result).not_to be_nil
        expect(result).to be false
      end
      it 'returns true for a training created by the same user' do
        result = @subject_instance_2.visible_to_user(@subject_instance_2.user)
        expect(result).not_to be_nil
        expect(result).to be true
      end
    end

    context 'with stored trainings, as a user with shared trainings' do
      before(:each) do
        @subject_instance_2.user.invite(subject.user, true, true, true)   # he wants to share everything
        subject.user.approve(@subject_instance_2.user, true, true, true)  # the other one approves
      end

      it 'returns true for any shared training, for both users' do
        results = subject.class.visible_to_user(subject.user)
        results.each do |shared_training_row|
          expect(shared_training_row.visible_to_user(subject.user)).to be true
          expect(shared_training_row.visible_to_user(@subject_instance_2.user)).to be true
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
