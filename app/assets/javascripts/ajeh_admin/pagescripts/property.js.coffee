pageScripts.register 'property', ->
  checkboxToggle = (checkboxSelector, toggleSelector) ->
    $(checkboxSelector).on 'change', ->
      handleCheckboxToggle(checkboxSelector, toggleSelector)
    handleCheckboxToggle(checkboxSelector, toggleSelector)

  handleCheckboxToggle = (checkboxSelector, toggleSelector) ->
    $toggle = $(toggleSelector)
    checked = $(checkboxSelector).prop('checked')
    if checked then $toggle.show() else $toggle.hide()

  checkboxToggle('#property_amenities_bedroom', '#field_property_bedroom_count')
  checkboxToggle('#property_amenities_bathroom', '#field_property_bathroom_count')

  window.onGoogleMapsLoad ->
    input = document.getElementById('google_place')
    google.maps.event.addDomListener input, 'keydown', (e) -> e.preventDefault() if e.keyCode is 13
    autocompleteOptions =
      componentRestrictions: { country: 'gb' }
      types: [ 'address' ]
    autocomplete = new google.maps.places.Autocomplete(input, autocompleteOptions)
    google.maps.event.addListener autocomplete, 'place_changed', ->
      place = autocomplete.getPlace()
      data =
        formatted_address: place.formatted_address
        lat: place.geometry.location.lat()
        lng: place.geometry.location.lng()
      $('#property_google_data').val(JSON.stringify(data))
