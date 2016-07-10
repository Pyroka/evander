require 'ostruct'
require 'erb'

module Evander

  class ErbContext < OpenStruct

    def render(template)
      ERB.new(template).result(binding)
    end

  end

end