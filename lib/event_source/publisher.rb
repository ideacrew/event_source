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
        publisher_constant_name = publisher_constant_for(relative_path, engine_prefix)
        publisher_klass_name = publisher_klass_for(relative_path, engine_prefix)
        Object.const_set(publisher_constant_name, publisher_klass_name.new)
        # EventSource::Logger.info "Initialized Publisher: #{constant_name} = #{klass_name}"
      end
    end

    def self.publisher_constant_for(relative_path, engine_prefix = nil)
      if engine_prefix
        [engine_prefix] + relative_path.split('/')
      else
        relative_path.split('/')
      end.reject(&:blank?).join('_').upcase
    end

    def self.publisher_klass_for(relative_path, engine_prefix = nil)
      if engine_prefix
        [engine_prefix, relative_path]
      else
        [relative_path]
      end.map{|ele| EventSource::Inflector.camelize(ele)}.join('::').constantize
    end
  end
end
