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
        :user
        # meeting => can be nil most of the times
      ])
    end

    context "[general methods]" do
      it_behaves_like( "(the existance of a class method)", [
        :calendar_unique_key
      ])

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
        :do_not_update,

        :get_short_name,
        :get_full_name,
        :get_verbose_name,
        :calendar_unique_key,
        :get_month_from_fin_code
      ])
    end


    describe "self.calendar_unique_key" do
      let(:year)    { ( 2012 .. 2017 ).to_a.sample }
      let(:rnd_day) { ( 1 .. 30 ).to_a.sample }
      let(:month)   { ['Ottobre','Novembre','Dicembre','Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno'].sample }
      let(:dates)   { ["#{ rnd_day }", "#{ rnd_day }-#{ rnd_day + 1 }"].sample }
      let(:place)   { City.all.sample.name }

      it "returns a String" do
        expect(
          FinCalendar.calendar_unique_key( year, month, dates, place )
        ).to be_a(String)
      end
      it "contains the key tokens" do
        result = FinCalendar.calendar_unique_key( year, month, dates, place )
        expect( result ).to include( year.to_s )
        normalized_month = FinCalendar::STANDARD_MONTH_NAMES.index( month.to_s.downcase.camelcase ) + 1
        expect( result ).to include( normalized_month.to_s )
        expect( result ).to include( dates.to_s )
        normalized_place = place.gsub(/[\s\,\:\-\_\']/,'').downcase
        expect( result ).to match( normalized_place )
      end
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
