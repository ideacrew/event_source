module Publishers
  module Publisher
    # Find all the publishers
    def register_publishers
      publisher_root = Pathname(__FILE__).dirname
      Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
        binding.pry

        # ORGANIZATION_PUBLISHER = OrganizationPublisher.new
      end
    end
  end
end
