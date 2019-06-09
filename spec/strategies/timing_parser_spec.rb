# frozen_string_literal: true

require 'rails_helper'
require 'timing_parser'
require 'wrappers/timing'

describe TimingParser, type: :strategy do
  it_behaves_like('(the existance of a class method)', [
                    :parse
                  ])
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.parse' do
    let(:minutes)   { (rand * 59).to_i }
    let(:seconds)   { (rand * 59).to_i }
    let(:hundreds)  { (rand * 59).to_i }

    context 'when parsing an empty string,' do
      subject { TimingParser.parse('') }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when parsing nil,' do
      subject { TimingParser.parse(nil) }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context "when parsing format #1 (dd\'dd\"dd)," do
      let(:fixture) { "#{minutes}\'#{seconds}\"#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(minutes)
      end
    end

    context "when parsing format #1 (\'dd\"dd)," do
      let(:fixture) { "\'#{seconds}\"#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context 'when parsing format #1 (dd"dd),' do
      let(:fixture) { "#{seconds}\"#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context 'when parsing format #1 ("dd),' do
      let(:fixture) { "\"#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(0)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context "when parsing format #1 (\'\"dd)," do
      let(:fixture) { "\'\"#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(0)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context "when parsing format #1 (dd\'dd)," do
      let(:fixture) { "#{minutes}\'#{seconds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(0)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(minutes)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'when parsing format #2 (dd:dd:dd),' do
      let(:fixture) { "#{minutes}:#{seconds}:#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(minutes)
      end
    end

    context 'when parsing format #2 (:dd:dd),' do
      let(:fixture) { ":#{seconds}:#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context 'when parsing format #2 (::dd),' do
      let(:fixture) { "::#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(0)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'when parsing format #2 (dd:dd.dd),' do
      let(:fixture) { "#{minutes}:#{seconds}.#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(minutes)
      end
    end

    context 'when parsing format #2 (:dd.dd),' do
      let(:fixture) { ":#{seconds}.#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end

    context 'when parsing format #2 (:.dd),' do
      let(:fixture) { ":.#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(0)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    context 'when parsing format #3 (dd.dd.dd),' do
      let(:fixture) { "#{minutes}.#{seconds}.#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(minutes)
      end
    end

    context 'when parsing format #3 (.dd.dd),' do
      let(:fixture) { ".#{seconds}.#{hundreds}" }
      subject { TimingParser.parse(fixture) }
      it 'returns a Timing instance' do
        expect(subject).to be_a(Timing)
      end
      it 'parses the correct value of hundreds' do
        expect(subject.hundreds).to eq(hundreds)
      end
      it 'parses the correct value of seconds' do
        expect(subject.seconds).to eq(seconds)
      end
      it 'parses the correct value of minutes' do
        expect(subject.minutes).to eq(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
