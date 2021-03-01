require 'dry/inflector'

module EventSource
  module Publisher
    # For the publisher_root directory and all its subdirectories, find each Publisher (file names that match: '*_publisher.rb'),
    # and using its file name instantiante an instance of the Publisher class and asign it to constant
    # @param [Pathname] publisher_root
    # @example
    #   File: organization_publisher.rb => ORGANIZATION_PUBLISHER = OrganizationPublisher.new
    #   File: parties/organization_publisher.rb => PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    def register_publishers(publisher_root = Pathname(__FILE__).dirname)
      Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
        constant_name =
          file.split('/').each { |f| f.upcase! }.join('::').chomp!('.RB')
        klass_name = EventSource::Inflector.camelize(file).chomp!('.rb')

        Object.const_set(constant_name, Class.new(klass_name))
        EventSource::Logger.info "Initialized Publisher: #{constant_name} = #{klass_name}"
      end
    end
  end
end
