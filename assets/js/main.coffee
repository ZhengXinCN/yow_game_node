require.config
  baseUrl: '/js'
  paths:
    "jquery": "//cdnjs.cloudflare.com/ajax/libs/jquery/1.8.2/jquery.min"
    "jquery.form": "//cdnjs.cloudflare.com/ajax/libs/jquery.form/3.09/jquery.form"
    "underscore": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min"
    "kinetic": "/kineticjs-4.0.5/kinetic"
    "jquery.bootstrap": "/bootstrap/js/bootstrap"
    "canvg": "/canvg-1.2/canvg"
    "q": "/q-0.8.10/q.min"
    "sylvester": "/sylvester-0-1-3/sylvester"
    "buzz": "/buzz-1.0.5/buzz"
    "statemachine": "/javascript-state-machine-1180b8ab3f0c23becf66899909a9163969be24f3/state-machine"
  shim:
    jquery:
      exports: "$"
    kinetic:
      exports: "Kinetic"
    canvg:
      deps: ["../canvg-1.2/rgbcolor"]
      exports: "canvg"
    underscore:
      exports: "_"
    'jquery.timeout':
      deps: ["jquery"]
      exports: "$"
    'jquery.bootstrap':
      deps: ['jquery']
    buzz:
      exports: "buzz"
    statemachine:
      exports: "StateMachine"
