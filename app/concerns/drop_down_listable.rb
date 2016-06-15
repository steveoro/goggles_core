require 'active_support'


=begin
  
= DropDownListable

  - version:  4.00.111.20140304
  - author:   Steve A.

  Concern that adds the capability to display an "includee" Model as a filtered drop-down
  list, by adding a method that returns an Array that can be subsequently a& easily
  decorated as a drop-down list by using a single HTML select statement.

=end
module DropDownListable
  extend ActiveSupport::Concern

  module ClassMethods
    # Label symbol corresponding to either a column name or a model method to be used
    # mainly in generating DropDown option lists.
    # For ActiveRecord::Base defaults to :i18n_short. To be overridden in siblings that
    # need to use different label methods.
    #
    def get_label_symbol
      :i18n_short
    end
    #-- -----------------------------------------------------------------------
    #++

# TODO Add support for multiple drop down order. 
# TODO Add support for custom sort order. 

    # Returns an Array of 2-items Arrays, in which each item is the ID of the record
    # (the key) and the other is assumed to be its displayable label.
    #
    # The resulting array has graphically this structure:
    #
    #    [
    #      [ label_1, key_1 ],
    #      [ label_2, key_2 ],
    #      [ label_3, key_3 ],
    #      ...
    #      [ label_N, key_N ]
    #    ]
    #
    # Each item of the resulting array is itself an array composed of tuples of
    # (label, key).
    #
    # This is perfect to pass as it is as a parameter for the options of a drop-down
    # html-select helper (hence, the method name).
    #
    # The default sorting of the resulting array is based upon the standard
    # alphanumeric sorting for each label item (which is array element #0
    # of each item in the resulting array).
    #
    # == Parameters:
    #
    # - where_condition: an ActiveRecord::Relation WHERE-clause; defaults to +nil+ (returns all records)
    # - key_sym: the key symbol/column name (defaults to :id)
    # - label_sym: the key symbol/column name (defaults to self.get_label_symbol())
    #
    # == Returns:
    # - an Array of arrays having the structure described above:
    #      [ [label1, key_value1], [label2, key_value2], ... ]
    #
    def to_dropdown( where_condition = nil, key_sym = :id, label_sym = get_label_symbol() )
      self.where( where_condition ).map{ |row|
        [row.send(label_sym), row.send(key_sym)]
      }.sort_by{ |ar| ar[0] }
    end

    # Create a custom not sorted dropdown list
    # This method is an extension of to_dropdown method
    # that only exclude the automatic sort by label
    # so the object to dropdown should be sorted before
    # and preserve order in the dropdown box
    #
    def to_unsorted_dropdown( where_condition = nil, key_sym = :id, label_sym = get_label_symbol() )
      self.where( where_condition ).map{ |row|
        [row.send(label_sym), row.send(key_sym)]
      }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
