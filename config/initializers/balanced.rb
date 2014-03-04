options = Rails.env.development? ? { logging_level: 'INFO' } : {}
Rails.logger.warn 'Set a value for Balanced\'s API secret with '\
                  '"Configuration[:balanced_api_key_secret] = \'foo_bar\' and restart the server.'
Balanced.configure(Configuration[:balanced_api_key_secret], options)
