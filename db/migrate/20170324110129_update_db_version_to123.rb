# frozen_string_literal: true

class UpdateDbVersionTo123 < ActiveRecord::Migration[5.0]

  def change
    AppParameter.update(
      AppParameter::PARAM_VERSIONING_CODE,
      AppParameter::PARAM_APP_NAME_FIELD.to_sym => GogglesCore::Version::FULL,
      AppParameter::PARAM_DB_VERSION_FIELD.to_sym => '1.23.01'
    )
  end

end
