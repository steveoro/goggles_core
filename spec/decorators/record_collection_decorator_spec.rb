require 'spec_helper'


describe RecordCollectionDecorator, type: :model do
  before :each do
    team = Team.find(1)
    rc = RecordCollector.new( team: team )
    @collection = rc.collect_from_results_having('25','50FA','M45','M','FOR')
  end

  subject { RecordCollectionDecorator.decorate(@collection) }


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :to_complete_html_list,
        :to_verbose_html_list,
        :to_short_html_list,
        :to_short_meeting_html_list,
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#to_complete_html_list" do
    it "returns an ActiveSupport::SafeBuffer" do
      expect( subject.to_complete_html_list ).to be_an_instance_of(ActiveSupport::SafeBuffer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#to_verbose_html_list" do
    it "returns an ActiveSupport::SafeBuffer" do
      expect( subject.to_verbose_html_list ).to be_an_instance_of(ActiveSupport::SafeBuffer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#to_short_html_list" do
    it "returns an ActiveSupport::SafeBuffer" do
      expect( subject.to_short_html_list ).to be_an_instance_of(ActiveSupport::SafeBuffer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#to_short_meeting_html_list" do
    it "returns an ActiveSupport::SafeBuffer" do
      expect( subject.to_short_meeting_html_list ).to be_an_instance_of(ActiveSupport::SafeBuffer)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
