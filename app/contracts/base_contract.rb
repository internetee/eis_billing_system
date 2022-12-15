module BaseContract
  ALLOWED_BASE_URL = [
    GlobalVariable::BASE_REGISTRY,
    GlobalVariable::BASE_REGISTRAR,
    GlobalVariable::BASE_AUCTION,
    GlobalVariable::BASE_EEID,
    GlobalVariable::ALLOWED_DEV_BASE_URLS
  ].freeze

  # def development_case
  #   [
  #     'https://registry.test',
  #     'https://registrar_center.test',
  #     'https://eeid.test',
  #     'https://auction_center.test',
  #     'https://auction.test',
  #   ]
  # end
end
