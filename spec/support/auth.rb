module Auth
  def login(user, first_name = 'TEST', last_name = 'OK')
    om = {
      'provider' => 'tara',
      'uid' => user.uid,
      'info' => {
        'first_name' => first_name,
        'last_name' => last_name,
        'name' => user.uid
      }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:tara, om)

    post auth_tara_callback_path(provider: 'tara')
  end
end
