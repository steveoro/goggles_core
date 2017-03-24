require 'rails_helper'


describe FinCalendar, type: :model do

  describe "[a well formed instance]" do
    subject { create(:fin_calendar) }

    context "[well formed category type instance]" do
      it "is a valid istance" do
        expect( subject ).to be_valid
      end
      it "has a valid season instance" do
        expect( subject.season ).to be_valid
      end

      it_behaves_like( "(belongs_to required models)", [
        :season,
        :user,
        :meeting
      ])
    end

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :calendar_year,
        :calendar_month,
        :calendar_date,
        :calendar_name,
        :calendar_place,

        :manifest_link,
        :startlist_link,
        :results_link,

        :fin_manifest_code,
        :fin_startlist_code,
        :fin_results_code,
        :goggles_meeting_code,

        :get_short_name,
        :get_full_name,
        :get_verbose_name,
        :calendar_unique_key,
        :get_month_from_fin_code
      ])
    end


    describe "#calendar_unique_key" do
      it "returns a String" do
        expect( subject.calendar_unique_key ).to be_a(String)
      end
    end

    describe "#get_month_from_fin_code" do
      it "returns a Fixnum" do
        expect( subject.get_month_from_fin_code ).to be_a(Fixnum)
      end
    end
  end
end
