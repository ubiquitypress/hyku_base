# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # HykuAddons initializer will include more modules and then close the work with this include
  #  include ::Hyrax::BasicMetadata

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'
end
