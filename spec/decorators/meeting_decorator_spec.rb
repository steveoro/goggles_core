require 'spec_helper'


describe MeetingDecorator, type: :model do
  include Rails.application.routes.url_helpers

  before :each do
#    @meeting = Meeting.find_by_id( ((rand * Meeting.count) % Meeting.count).to_i + 1 )
    # FIXME Randomize correctly this: (the above gets some wrong IDs)
    @meeting = Meeting.find_by_id( 13105 )
    expect( @meeting ).to be_an_instance_of(Meeting)
    @decorated_instance = MeetingDecorator.decorate( @meeting )
  end

  subject { @decorated_instance }


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method returning strings)", [
        :get_css_class_for_season_type
      ]
    )
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_logo_for_season_type" do
    it_behaves_like( "(the existance of a method)", [:get_logo_for_season_type] )

    context "while called on a well-defined instance," do
      it "returns either an ActiveSupport::SafeBuffer or a String" do
        result = subject.get_logo_for_season_type
        expect( result ).to be_an_instance_of(ActiveSupport::SafeBuffer).or be_an_instance_of(String)
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_linked_short_name" do
    it "responds to #get_linked_short_name method" do
      expect( subject ).to respond_to( :get_linked_short_name )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_short_name ).to include( 'href' )
    end
    it "returns an HTML link to the meeting show full path" do
      expect( subject.get_linked_short_name ).to include( meeting_show_full_path(id: subject.id) )
    end
    it "returns a string containing the meeting short name" do
      expect( subject.get_linked_short_name ).to include( ERB::Util.html_escape(subject.get_short_name) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_linked_city_with_date" do
    it "responds to #get_linked_short_name method" do
      expect( subject ).to respond_to( :get_linked_city_with_date )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_city_with_date ).to include( 'href' )
    end
    it "returns an HTML link to the meeting show full path" do
      expect( subject.get_linked_city_with_date ).to include( meeting_show_full_path(id: subject.id) )
    end
    it "returns a string containing the meeting shortest name" do
      expect( subject.get_linked_city_with_date ).to include( ERB::Util.html_escape(subject.get_city) )
    end
    it "returns a string containing the meeting scheduled date" do
      expect( subject.get_linked_city_with_date ).to include( ERB::Util.html_escape(subject.get_scheduled_date) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_linked_full_name_with_date" do
    it "responds to #get_linked_full_name_with_date method" do
      expect( subject ).to respond_to( :get_linked_full_name_with_date )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_full_name_with_date ).to include( 'href' )
    end
    it "returns an HTML link to the meeting show full path" do
      expect( subject.get_linked_full_name_with_date ).to include( meeting_show_full_path(id: subject.id) )
    end
    it "returns a string containing the meeting full name" do
      expect( subject.get_linked_full_name_with_date ).to include( ERB::Util.html_escape(subject.get_full_name) )
    end
    it "returns a string containing the meeting scheduled date" do
      expect( subject.get_linked_full_name_with_date ).to include( ERB::Util.html_escape(subject.get_scheduled_date) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_linked_full_name" do
    it "responds to #get_linked_full_name method" do
      expect( subject ).to respond_to( :get_linked_full_name )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_full_name ).to include( 'href' )
    end
    it "returns an HTML link to the meeting show full path" do
      expect( subject.get_linked_full_name ).to include( meeting_show_full_path(id: subject.id) )
    end
    it "returns a string containing the meeting full name" do
      expect( subject.get_linked_full_name ).to include( ERB::Util.html_escape(subject.get_full_name) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_linked_name" do
    it "responds to #get_linked_name method" do
      expect( subject ).to respond_to( :get_linked_name )
    end

    context "without parameters" do
      it "returns an HTML link" do
        expect( subject.get_linked_name ).to include( 'href' )
      end
      it "returns an HTML link to the meeting show full path" do
        expect( subject.get_linked_name ).to include( meeting_show_full_path(id: subject.id) )
      end
      it "returns a string containing the meeting short name as default" do
        expect( subject.get_linked_name ).to include( ERB::Util.html_escape(subject.get_short_name) )
      end
    end

    context "with get_short_name as parameter" do
      it "returns an HTML link" do
        expect( subject.get_linked_name( :get_short_name ) ).to include( 'href' )
      end
      it "returns an HTML link to the meeting show full path" do
        expect( subject.get_linked_name( :get_short_name ) ).to include( meeting_show_full_path(id: subject.id) )
      end
      it "returns a string containing the meeting short name" do
        expect( subject.get_linked_name( :get_short_name ) ).to include( ERB::Util.html_escape(subject.get_short_name) )
      end
    end

    context "with :get_full_name as parameter" do
      it "returns an HTML link" do
        expect( subject.get_linked_name( :get_full_name ) ).to include( 'href' )
      end
      it "returns an HTML link to the meeting show full path" do
        expect( subject.get_linked_name( :get_full_name ) ).to include( meeting_show_full_path(id: subject.id) )
      end
      it "returns a string containing the meeting short name" do
        expect( subject.get_linked_name( :get_full_name ) ).to include( ERB::Util.html_escape(subject.get_full_name) )
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++

  
  describe "#get_session_warm_up_times" do
    it "responds to #get_session_warm_up_times method" do
      expect( subject ).to respond_to( :get_session_warm_up_times )
    end
    it "returns a string" do
      expect( subject.get_session_warm_up_times ).to be_a_kind_of( String )
    end
  end
  #-- --------------------------------------------------------------------------
  #++

  
  describe "#get_session_begin_times" do
    it "responds to #get_session_begin_times method" do
      expect( subject ).to respond_to( :get_session_begin_times )
    end
    it "returns a string" do
      expect( subject.get_session_begin_times ).to be_a_kind_of( String )
    end
  end
  #-- --------------------------------------------------------------------------
  #++

  
  describe "#get_linked_swimming_pool" do
    it "responds to #get_linked_swimming_pool" do
      expect( subject ).to respond_to( :get_linked_swimming_pool )
    end

    context "meeting with defined swimming pool" do
      it "returns a string" do
        expect( subject.get_linked_swimming_pool ).to be_a_kind_of( String )
      end
      it "returns an HTML link" do
        expect( subject.get_linked_swimming_pool ).to include( 'href' )
      end
      it "returns an HTML link to the swimming pool path" do
        expect( subject.get_linked_swimming_pool ).to include( swimming_pool_path(id: subject.get_swimming_pool.id) )
      end
      it "returns a string containing the swimming pool name" do
        expect( subject.get_linked_swimming_pool ).to include( ERB::Util.html_escape(subject.get_swimming_pool.get_full_name) )
      end
      it "returns a string containing the swimming pool choosen type name" do
        expect( subject.get_linked_swimming_pool( :get_verbose_name ) ).to include( ERB::Util.html_escape(subject.get_swimming_pool.get_verbose_name) )
      end
    end

    context "meeting without defined swimming pool" do
      before :each do
        @empty_meeting = create( :meeting ).decorate  
      end
      
      it "returns a string" do
        expect( @empty_meeting.get_linked_swimming_pool ).to be_a_kind_of( String )
      end
      it "returns an HTML link" do
        expect( @empty_meeting.get_linked_swimming_pool ).to include( '?' )
      end
      it "returns an HTML link" do
        expect( @empty_meeting.get_linked_swimming_pool ).not_to include( 'href' )
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
