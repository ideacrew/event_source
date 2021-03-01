require 'dry/inflector'

module EventSource
  module Publisher


    # For the root directory and all its subdirectories, find each Publisher (file names that match: '*_publisher.rb'),
    # and using its file name instantiante an instance of the Publisher class and asign it to constant
    # @param [Pathname] publisher_root
    # @example
    #   File: organization_publisher.rb => ORGANIZATION_PUBLISHER = OrganizationPublisher.new
    #   File: parties/organization_publisher.rb => PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    def self.register_publishers(publisher_root = Pathname(__FILE__).dirname)
      Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
        relative_path = file.split(publisher_root.to_s).last.chomp('.rb')
        constant_name = relative_path.split('/').reject(&:blank?).join('_').upcase
        klass_name = EventSource::Inflector.camelize(relative_path).constantize
        Object.const_set(constant_name, klass_name.new)
        # EventSource::Logger.info "Initialized Publisher: #{constant_name} = #{klass_name}"
      end
    end
  end
end