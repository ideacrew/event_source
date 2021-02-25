require_relative 'parties/organization_publisher'
require_relative 'parties/organization_listener'

module Publishers
  module Publisher

    ::PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new

    ::PARTIES_ORGANIZATION_PUBLISHER.subscribe(Parties::OrganizationListener.new)


    # Find all defined publishers, instantiante an instance and assiggn to constant
    # @example
    #   File: organization_publisher.rb => ORGANIZATION_PUBLISHER = OrganizationPublisher.new
    #   File: parties/organization_publisher.rb => PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    def register_publishers
      publisher_root = Pathname(__FILE__).dirname


      Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
        constant_name =
          file.split('/').each { |f| f.upcase! }.join('::').chomp!('.RB')
        klass_name = '' # TODO need titlecase-like function
      end
    end
  end
end
