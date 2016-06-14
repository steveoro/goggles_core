# encoding: UTF-8


=begin

= ViewColumnStringRegexped

  - version:  4.00.665
  - author:   Steve A.

  Customized ViewColumn extension class for WiceGrid.

  Currently this does the same rendering as the standard ViewColumnString.

  Remember that class name must be added to the array Wice::Defaults::ADDITIONAL_COLUMN_PROCESSOR,
  in config/initializers/wice_grid_config.rb.

=end
class ViewColumnStringRegexped < Wice::Columns::ViewColumn

  attr_accessor :negation, :auto_reloading_input_with_negation_checkbox
  #-- -------------------------------------------------------------------------
  #++

  def render_filter_internal(params) #:nodoc:
    @contains_a_text_input = true
    css_class = 'form-control input-sm ' + (auto_reload ? 'auto-reload' : '')

    if negation
      self.auto_reloading_input_with_negation_checkbox = true if auto_reload

      @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query(v: '')
      @query2, _, parameter_name2, @dom_id2 = form_parameter_name_id_and_query(n: '')

      '<div class="text-filter-container">' +
        text_field_tag(parameter_name, params[:v], size: 8, id: @dom_id, class: css_class) +
        if defined?(Wice::Defaults::NEGATION_CHECKBOX_LABEL) && ! Wice::ConfigurationProvider.value_for(:NEGATION_CHECKBOX_LABEL).blank?
          Wice::ConfigurationProvider.value_for(:NEGATION_CHECKBOX_LABEL)
        else
          ''
        end +
        check_box_tag(parameter_name2, '1', (params[:n] == '1'),
          id: @dom_id2,
          title: NlMessage['negation_checkbox_title'],
          class: "negation-checkbox #{css_class}") +
        '</div>'
    else
      @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query('')
      text_field_tag(parameter_name, (params.blank? ? '' : params), size: 8, id: @dom_id, class: css_class)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  def yield_declaration_of_column_filter #:nodoc:
    if negation
      {
        templates: [@query, @query2],
        ids:       [@dom_id, @dom_id2]
      }
    else
      {
        templates: [@query],
        ids:       [@dom_id]
      }
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  def has_auto_reloading_input? #:nodoc:
    auto_reload
  end
  #-- -------------------------------------------------------------------------
  #++

  def auto_reloading_input_with_negation_checkbox? #:nodoc:
    self.auto_reloading_input_with_negation_checkbox
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++


=begin

= ConditionsGeneratorColumnStringRegexped

  - version:  4.00.665
  - author:   Steve A.

  Customized ConditionsGeneratorColumn extension class for WiceGrid.

  Forces the usage of RLIKE or REGEXP instead of LIKE for any query text. Any compound
  search text is splitted in search tokens before preparing the query.

  Remember that class name must be added to the array Wice::Defaults::ADDITIONAL_COLUMN_PROCESSOR,
  in config/initializers/wice_grid_config.rb.

=end
class ConditionsGeneratorColumnStringRegexped < Wice::Columns::ConditionsGeneratorColumn

  # Generate an array of search conditions given the parameters.
  #
  def self.generate_query_conditions( table_alias, field_name, search_text, negation = '' )
    search_tokens = search_text.split(/\s+/)
    query_text = []
    search_tokens.each do |token|
      query_text << "#{table_alias}.#{field_name} REGEXP(?)"
    end
    [
      " #{negation} (" << query_text.join(" AND ") << ")"
    ] + search_tokens
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns an array of valid SQL string search conditions, using the specified
  # table_alias and options.
  #
  def generate_conditions( table_alias, opts )
    if opts.kind_of? String
      string_fragment = opts
      negation = ''
    elsif (opts.kind_of? Hash) && opts.has_key?(:v)
      string_fragment = opts[:v]
      negation = opts[:n] == '1' ? 'NOT' : ''
    else
      Wice.log "invalid parameters for the grid string filter - must be a string: #{opts.inspect} or a Hash with keys :v and :n"
      return false
    end
    if string_fragment.empty?
      return false
    end
    ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
      @column_wrapper.alias_or_table_name(table_alias),
      @column_wrapper.name,
      string_fragment,
      negation
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
