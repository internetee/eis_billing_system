# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-importmap-autoloader", to: "stimulus-importmap-autoloader.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.js"
pin "nouislider", to: "https://ga.jspm.io/npm:nouislider@15.5.1/dist/nouislider.js"
pin "wnumb", to: "https://ga.jspm.io/npm:wnumb@1.2.0/wNumb.js"
