module EventSource
  class PublishOperation

  	attr_reader :subject

  	def initialize(publish_proxy)
  	  @subject = publish_proxy
  	end

  	def call(args)
      @subject.call(*args)
    end
  end
end