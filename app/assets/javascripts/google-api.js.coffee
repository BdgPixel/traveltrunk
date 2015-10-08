placeSearch = undefined
autocomplete = undefined
componentForm =
  street_number: 'short_name'
  route: 'long_name'
  locality: 'long_name'
  administrative_area_level_1: 'short_name'
  country: 'long_name'
  postal_code: 'short_name'

initAutocomplete = ->
  # Create the autocomplete object, restricting the search to geographical
  # location types.
  autocomplete = new (google.maps.places.Autocomplete)(document.getElementById('autocomplete'), types: [ 'geocode' ])
  # When the user selects an address from the dropdown, populate the address
  # fields in the form.
  autocomplete.addListener 'place_changed', fillInAddress
  return

fillInAddress = ->
  # Get the place details from the autocomplete object.
  place = autocomplete.getPlace()
  for component of componentForm
    document.getElementById(component).value = ''
    document.getElementById(component).disabled = false
  # Get each component of the address from the place details
  # and fill the corresponding field on the form.
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
    lat: parseFloat $('#lat').val()
    lng: parseFloat $('#long').val()

  map = new (google.maps.Map)(document.getElementById('map'),
    center: myLatLng
    zoom: 15)

  marker = new (google.maps.Marker)(
    map: map
    position: myLatLng)

  # infowindow = new (google.maps.InfoWindow)
  # service = new (google.maps.places.PlacesService)(map)
  # service.getDetails { placeId: 'ChIJN1t_tDeuEmsRUsoyG83frY4' }, (place, status) ->
  #   if status == google.maps.places.PlacesServiceStatus.OK
  #     marker = new (google.maps.Marker)(
  #       map: map
  #       position: place.geometry.location)
  #     google.maps.event.addListener marker, 'click', ->
  #       infowindow.setContent place.name
  #       infowindow.open map, this
  #       return
  #   return
  return


$(document).ready ->
  if $("#autocomplete").length > 0
    initAutocomplete()

  if $("#map").length > 0
    initMap()

