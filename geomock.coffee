###
(c) 2011 Jan Monschke
v1.0.1
GeoMock is licensed under the MIT license.
###


window.GeoMock = 

  _backup: {} 
  
  _adding:  ['delay', 'shouldFail', 'failsAt', 'errorMessage', 'waypoints', '_geoCall']

  _replacing: ['getCurrentPosition', 'watchPosition', 'clearWatch']

  _watchIds: []

  install: () ->
    unless navigator? 
      window.navigator = {}

    unless navigator.geolocation? 
      window.navigator.geolocation = {}

    for attr in this._replacing
      this._backup[attr] = navigator.geolocation[attr]
    

    GeoMock._geolocation = navigator.geolocation;

    navigator.geolocation = {};

    navigator.geolocation.delay = 1000
      
    navigator.geolocation.shouldFail = false
    navigator.geolocation.failsAt = -1
    navigator.geolocation.errorMessage = "There was an error retrieving the position!"
      
    navigator.geolocation.currentTimeout = -1
      
    navigator.geolocation.lastPosReturned = 0
      
    navigator.geolocation._sanitizeLastReturned = ->
      if @lastPosReturned > @waypoints.length-1
        @lastPosReturned = 0
      
    navigator.geolocation._geoCall = (method, success, error) ->
      if @shouldFail and error?
        @currentTimeout = window[method].call null, =>
          error @errorMessage
        , @delay
        GeoMock._watchIds.push @currentTimeout
      else
        if success?
          @currentTimeout = window[method].call null, =>
            success @waypoints[@lastPosReturned++]
            do @_sanitizeLastReturned
          , @delay
          GeoMock._watchIds.push @currentTimeout
      
    navigator.geolocation.getCurrentPosition = (success, error) ->
      @_geoCall "setTimeout", success, error
    
    navigator.geolocation.watchPosition = (success, error) ->
      @_geoCall "setInterval", success, error
      @currentTimeout
    
    navigator.geolocation.clearWatch = (id) ->
      clearInterval id
    
    navigator.geolocation.waypoints = [
      {coords : {latitude : 52.5168, longitude : 13.3889, accuracy: 1500 }},
      {coords : {latitude : 52.5162, longitude : 13.3890, accuracy: 1334 }},
      {coords : {latitude : 52.5154, longitude : 13.3890, accuracy: 631  }},
      {coords : {latitude : 52.5150, longitude : 13.3890, accuracy: 361  }},
      {coords : {latitude : 52.5144, longitude : 13.3890, accuracy: 150  }},
      {coords : {latitude : 52.5138, longitude : 13.3890, accuracy: 65   }},
      {coords : {latitude : 52.5138, longitude : 13.3895, accuracy: 65   }},
      {coords : {latitude : 52.5139, longitude : 13.3899, accuracy: 65   }},
      {coords : {latitude : 52.5140, longitude : 13.3906, accuracy: 65   }},
      {coords : {latitude : 52.5140, longitude : 13.3910, accuracy: 65   }}
    ]

  uninstall: () ->
    if GeoMock._geolocation

      for attr in @_replacing
        navigator.geolocation[attr] = this._backup[attr];

      for attr in @_adding
        delete navigator.geolocation[attr]

      for id in @_watchIds
        clearInterval id
        clearTimeout id
