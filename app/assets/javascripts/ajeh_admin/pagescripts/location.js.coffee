pageScripts.register 'location', ->
  window.onGoogleMapsLoad ->
    input = document.getElementById('google_place')
    google.maps.event.addDomListener input, 'keydown', (e) -> e.preventDefault() if e.keyCode is 13
    autocompleteOptions =
      componentRestrictions: { country: 'gb' }
      types: [ '(cities)' ]
    autocomplete = new google.maps.places.Autocomplete(input, autocompleteOptions)
    google.maps.event.addListener autocomplete, 'place_changed', ->
      place = autocomplete.getPlace()
      data =
        formatted_address: place.formatted_address
        lat: place.geometry.location.lat()
        lng: place.geometry.location.lng()
        ne_lat: place.geometry.viewport.getNorthEast().lat()
        ne_lng: place.geometry.viewport.getNorthEast().lng()
        sw_lat: place.geometry.viewport.getSouthWest().lat()
        sw_lng: place.geometry.viewport.getSouthWest().lng()
      $('#location_google_data').val(JSON.stringify(data))
