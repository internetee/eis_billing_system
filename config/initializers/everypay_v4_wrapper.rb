EverypayV4Wrapper.configure do |config|
  config.secret_key = "super-key"

  # Everypay requires a special format for presenting data on the amount of payment.
  # These settings allow you to customize how the amount is formed. The amount format is formatted using the money gem
  # below are the default values. This means that if you do not set these values directly or in configurations, then such values will remain.

  # The most important here are the flag and the field, it is advisable to leave the rest of the settings by default (only if some conditions for using EveryPay do not change)

  # True value - gives permission to edit the payment amount
  config.currency_translation_flag = false
  # This is where you specify the field in the parameters that you want to format. As a rule, this is the field transaction_amount
  config.currency_translation_field = 'transaction_amount'
  config.currency_translation_currency = 'EUR'
  config.currency_translation_symbol = nil
  config.currency_translation_decimal_mark = '.'
  config.currency_translation_thousands_separator = false

  # When a URL with the necessary parameters is formed, it is important that there are no spaces in the fields where the description goes, but underscores.

  # That is, this kind of url is not acceptable: https://https://igw-demo.every-pay.com/lp?custom_field_1=this is description
  # Correct url option https://https://igw-demo.every-pay.com/lp?custom_field_1=this_is_description
  #
  # At the bottom, these parameters allow you to enable the ability of the gem to automatically format and substitute for spaces - underscore
  config.separator_flag = true
  config.separator_symbol = '_'
end