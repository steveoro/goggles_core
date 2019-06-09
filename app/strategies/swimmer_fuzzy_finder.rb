# frozen_string_literal: true

require 'conditions_generator_column_string_regexped' # Used to generate simple_search query condition

#
# = SwimmerFuzzyFinder
#
#  - Goggles framework vers.:  6.071
#  - author: Steve A.
#
#  Fuzzy-finder class used to retrieve lists of Swimmer instances based
#  upon a versatile "fuzzy" search query.
#
class SwimmerFuzzyFinder

  attr_reader :first_name, :last_name, :complete_name, :year_of_birth, :gender_code,
              :limit

  # Executes the search call.
  #
  # == Params:
  # An Hash-like list of parameter values, specifying the corresponding Swimmer
  # field value.
  #
  # All parameters are optional but at least one must be specified.
  # Whenever present, the couple :first_name & :last_name take precedence
  # over :complete_name (even though this is the "main" search field).
  #
  # - :first_name,
  # - :last_name,
  # - :complete_name (main search field),
  # - :year_of_birth (either as String or Fixnum),
  # - :gender_type_id (takes precedence over ;gender_code)
  # - :gender_code (specifying this will issue an additional query)
  # - :limit for the results found
  #
  # == Returns:
  # A list of matching Swimmer instances; an empty array otherwise.
  #
  def self.call(*args)
    new(*args).call
  end

  # Creates a new finder instance. See self.call() for parameters.
  #
  def initialize(params)
    # These two may be null inside a Swimmer row:
    @first_name     = params[:first_name]
    @last_name      = params[:last_name]
    # :complete_name is never null in Swimmer and thus is the main search field
    @complete_name  = params[:complete_name]
    @year_of_birth  = params[:year_of_birth]
    @gender_type_id = params[:gender_type_id]
    @gender_code    = params[:gender_code]
    @limit          = params[:limit]
    normalize_names
    normalize_gender
  end

  # Executes the search given the stored parameters.
  #
  def call
    filter_by_gender(filter_by_birth(search_by_name))
  end

  private

  # Swimmer name parameter normalizer.
  # It assumes that all the variables may be nil.
  #
  # When either complete_name or the couple last_name & first_name are not nil or
  # empty, the result of the normalization is to define a coherent value for all
  # 3 fields, assuming that for most DB rows it is expected that:
  #
  #   complete_name = last_name + ' ' + first_name
  #
  def normalize_names
    # When given, last_name & first_name take precendece over complete_name:
    if !@first_name.to_s.empty? || !@last_name.to_s.empty?
      @complete_name = [@last_name, @first_name].join(' ')

    elsif !@complete_name.to_s.empty?
      # Normalize multi-space separator between last_name and first_name.
      # We must find a "separator length" that at least results in a last_name+first_name
      # array:
      splitted_name = @complete_name.gsub(/\s{3,}/, '  ').split('  ')
      splitted_name = (splitted_name[0]).split(' ') if splitted_name.size < 2
      if splitted_name.size == 2 # Use last & first name only when the splitting is certain
        @last_name  = splitted_name[0]
        @first_name = splitted_name.reject { |s| s == @last_name }.join(' ')
      end
      @complete_name = @complete_name.gsub(/\s+/, ' ')
    end
  end

  # Swimmer gender type parameter normalizer.
  # It assumes that all the variables may be nil.
  # The result of the normalization is a GenderType.id usable for a WHERE clause.
  #
  def normalize_gender
    @gender_type_id = GenderType::TYPES_HASH.key(@gender_code) if @gender_code
  end
  #-- --------------------------------------------------------------------------
  #++

  # Searches swimmers based on possible name matches.
  # Returns an array of matching rows; an empty array when no matches are found.
  #
  def search_by_name
    # 1) Simple query, searching for a name "as-is":
    swimmers = Swimmer.where(complete_name: @complete_name).limit(@limit)

    # 2) RegExp query on name:
    if swimmers.count == 0 && !@complete_name.to_s.empty?
      # Search among Swimmers for an equal complete name:
      name_clause = ConditionsGeneratorColumnStringRegexped
                    .generate_query_conditions('swimmers', 'complete_name', @complete_name)
      swimmers = Swimmer.where(name_clause).limit(@limit)
    end

    # 3) Fuzzy search on a pre-filtered complete_name
    if swimmers.count == 0 && !@complete_name.to_s.empty?
      matcher = FuzzyStringMatcher.new(prefilter_by_name_start, :complete_name)
      final_bias_score, results = matcher.seek_deep_match(
        @complete_name,
        FuzzyStringMatcher::BIAS_SCORE_MAX, # Starting target score
        FuzzyStringMatcher::BIAS_SCORE_MIN  # Min. acceptable score
      )
      swimmers = results.map { |hash| hash[:row] }
    end
    swimmers.to_a
  end

  # (Pre-)Filters Swimmers based on the most significant part of the complete_name.
  # Returns the filtered set.
  #
  def prefilter_by_name_start
    search_token = '%' + @complete_name[0..3] + '%'
    Swimmer.where('(complete_name LIKE ?)', search_token).limit(@limit)
  end

  # Filters Swimmers array based on year of birth.
  # Returns the filtered array.
  #
  def filter_by_birth(swimmers_list)
    if @year_of_birth
      year = @year_of_birth.to_i
      swimmers_list.find_all do |s|
        (s.year_of_birth == year && !s.is_year_guessed) ||
          (year - 4..year + 4).include?(s.year_of_birth)
      end
    else
      swimmers_list
    end
  end

  # Filters Swimmers array based on gender type id.
  # Returns the filtered array.
  #
  def filter_by_gender(swimmers_list)
    if @gender_type_id
      swimmers_list.find_all { |s| s.gender_type_id == @gender_type_id.to_i }
    else
      swimmers_list
    end
  end
  #-- --------------------------------------------------------------------------
  #++

end
