require.config
  baseUrl: '/js'
  paths:
    "jquery": "//cdnjs.cloudflare.com/ajax/libs/jquery/1.8.2/jquery.min"
    "jquery.timeout": "/jquery-timeout-read-only/jquery.timeout"
    "underscore": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min"
    "kinetic": "//www.html5canvastutorials.com/libraries/kinetic-v4.0.3"
    "jquery.bootstrap": "/bootstrap/js/bootstrap"
    "canvg": "/canvg-1.2/canvg"
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
