# encoding: utf-8
require 'draper'


=begin

= SwimmingPoolReviewDecorator

  - version:  4.00.313.20140610
  - author:   Steve A.

  Decorator for the SwimmingPoolReview model.
  Contains all presentation-logic centered methods.

=end
class SwimmingPoolReviewDecorator < Draper::Decorator
  delegate_all
end
