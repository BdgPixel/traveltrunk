placeSearch = undefined
# autocomplete = undefined
componentForm =
  street_number: 'short_name'
  route: 'long_name'
  locality: 'long_name'
  administrative_area_level_1: 'short_name'
  country: 'long_name'
  postal_code: 'short_name'

root = exports ? this

initAutocomplete = (selector) ->
  autocomplete = new (google.maps.places.Autocomplete)(document.getElementById(selector), types: [ 'geocode' ])
  autocomplete.addListener 'place_changed', () ->
    place = autocomplete.getPlace()
    if $('.lat').length > 0 and $('.lng').length > 0
      $('.lat').val place.geometry.location.lat()
      $('.lng').val place.geometry.location.lng()

    for component of componentForm
      document.getElementById(component).value = ''
      document.getElementById(component).disabled = false

    i = 0
    while i < place.address_components.length
      addressType = place.address_components[i].types[0]
      if componentForm[addressType]
        val = place.address_components[i][componentForm[addressType]]
        document.getElementById(addressType).value = val
      i++

    return

  return

fillInAddress = ->
  place = autocomplete.getPlace()
  if $('.lat').length > 0 and $('.lng').length > 0
    $('.lat').val place.geometry.location.lat()
    $('.lng').val place.geometry.location.lng()

  for component of componentForm
    document.getElementById(component).value = ''
    document.getElementById(component).disabled = false

  i = 0
  while i < place.address_components.length
    addressType = place.address_components[i].types[0]
    if componentForm[addressType]
      val = place.address_components[i][componentForm[addressType]]
      document.getElementById(addressType).value = val
    i++

  return

geolocate = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition (position) ->
      geolocation =
        lat: position.coords.latitude
        lng: position.coords.longitude
      circle = new (google.maps.Circle)(
        center: geolocation
        radius: position.coords.accuracy)
      autocomplete.setBounds circle.getBounds()

      return

  return

initMap = ->
  myLatLng =
    lat: parseFloat $('.lat').val()
    lng: parseFloat $('.lng').val()

  map = new (google.maps.Map)(document.getElementById('map'),
    center: myLatLng
    zoom: 15
    scrollwheel: false)

  marker = new (google.maps.Marker)(
    map: map
    position: myLatLng)

  return

$(document).ready ->
  if $('#autocomplete').length > 0
    initAutocomplete('autocomplete')

  if $('#autocompleteMobile').length > 0
    initAutocomplete('autocompleteMobile')

  if $('#map').length > 0
    initMap()
