# frozen_string_literal: true

module MojFile
  module Logging
    private

    def log_result(params)
      params.merge!(action: self.class::ACTION_NAME)
      params.fetch(:error, nil) ? logger.error(params) : logger.info(params)
    end
  end
end
