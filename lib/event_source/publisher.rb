require 'dry/inflector'

module EventSource
  module Publisher

    # For the publisher_root directory and all its subdirectories, find each Publisher (file names that match: '*_publisher.rb'),
    # and using its file name instantiante an instance of the Publisher class and asign it to constant
    # @param [Pathname] publisher_root
    # @example
    #   File: organization_publisher.rb => ORGANIZATION_PUBLISHER = OrganizationPublisher.new
    #   File: parties/organization_publisher.rb => PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    def self.register_publishers(publisher_root = Pathname(__FILE__).dirname, engine_prefix = nil)
      Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
        relative_path = file.match(/^#{publisher_root}\/(.*)\.rb/)[1]

        const_parts = [relative_path.split('/')]
        const_parts = ([engine_prefix.upcase] + const_parts) if engine_prefix
        constant_name = const_parts.reject(&:blank?).join('_').upcase

        klass_name = if engine_prefix
          [engine_prefix, relative_path].map{|ele| EventSource::Inflector.camelize(ele)}.join('::').constantize
        else
          EventSource::Inflector.camelize(relative_path).constantize
        end

        Object.const_set(constant_name, klass_name.new)
        # EventSource::Logger.info "Initialized Publisher: #{constant_name} = #{klass_name}"
      end
    end
  end
end