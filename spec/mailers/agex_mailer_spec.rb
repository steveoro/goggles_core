require 'rails_helper'
require 'ffaker'

require 'framework/application_constants'


describe AgexMailer, type: :mailer do
  let(:user)  { create(:user) }

  context "#exception_mail()" do
    let(:description) { "#{FFaker::Lorem.paragraph} error intercepted!" }
    let(:backtrace)   { ["#{FFaker::Lorem.paragraph} row1", "#{FFaker::Lorem.paragraph} row2", "#{FFaker::Lorem.paragraph} row3"] }
    subject           { AgexMailer.exception_mail( user, description, backtrace ) }

    it 'renders the receiver email' do
      expect( subject.to.first ).to include( WEB_ADMIN_EMAILS )
    end
    it 'renders the description in the subject' do
      expect( subject.subject ).to match( description )
    end
    it 'renders the hostname in the subject' do
      expect( subject.subject ).to match( WEB_MAIN_DOMAIN_NAME )
    end
    it 'renders the user_name in the message' do
      expect( subject.body.encoded ).to match( user.name )
    end
    it 'renders the backtrace in the message' do
      backtrace.each do |row|
        expect( subject.body.encoded ).to include(row)
      end
    end

    describe "#deliver" do
      it "sends an e-mail" do
        expect{ subject.deliver }.to change{ AgexMailer.deliveries.size }
      end
      it "delivers the generated message" do
        subject.deliver
        expect(
          AgexMailer.deliveries.last.body.encoded
        ).to match( subject.body.encoded )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "#action_notify_mail()" do
    let(:action_name)         { "#{FFaker::Lorem.word} action" }
    let(:action_description)  { "#{FFaker::Lorem.word} description" }
    subject                   { AgexMailer.action_notify_mail( user, action_name, action_description ) }

    it 'renders the receiver email' do
      expect( subject.to.first ).to include( WEB_ADMIN_EMAILS )
    end
    it 'renders the action_name in the subject' do
      expect( subject.subject ).to match(action_name)
    end
    it 'renders the hostname in the subject' do
      expect( subject.subject ).to match( WEB_MAIN_DOMAIN_NAME )
    end
    it 'renders the user_name in the message' do
      expect( subject.body.encoded ).to match( user.name )
    end
    it 'renders the action_description in the message' do
      expect( subject.body.encoded ).to match( action_description )
    end

    describe "#deliver" do
      it "sends an e-mail" do
        expect{ subject.deliver }.to change{ AgexMailer.deliveries.size }
      end
      it "delivers the generated message" do
        subject.deliver
        expect(
          AgexMailer.deliveries.last.body.encoded
        ).to match( subject.body.encoded )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "#report_abuse_mail()" do
    let(:user_involved) { create(:user) }
    let(:entity_name)   { "#{FFaker::Lorem.word}EntityName" }
    let(:entity_id)     { ((rand * 100) % 100).to_i + 1 }
    let(:entity_title)  { "#{FFaker::Lorem.word} title" }
    subject             { AgexMailer.report_abuse_mail( user, user_involved, entity_name, entity_id, entity_title ) }

    it 'renders the receiver email' do
      expect( subject.to.first ).to include( WEB_ADMIN_EMAILS )
    end
    it 'renders the entity_name in the subject' do
      expect( subject.subject ).to match( entity_name )
    end
    it 'renders ID:entity_id in the subject' do
      expect( subject.subject ).to match( "ID:#{entity_id}" )
    end
    it 'renders the hostname in the subject' do
      expect( subject.subject ).to match( WEB_MAIN_DOMAIN_NAME )
    end
    it 'renders the name of the sender user in the message' do
      expect( subject.body.encoded ).to match( user.name )
    end
    it 'renders the name of the involved user in the message' do
      expect( subject.body.encoded ).to match( user_involved.name )
    end
    it 'renders the entity_title in the message' do
      expect( subject.body.encoded ).to match( entity_title )
    end

    describe "#deliver" do
      it "sends an e-mail" do
        expect{ subject.deliver }.to change{ AgexMailer.deliveries.size }
      end
      it "delivers the generated message" do
        subject.deliver
        expect(
          AgexMailer.deliveries.last.body.encoded
        ).to match( subject.body.encoded )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end