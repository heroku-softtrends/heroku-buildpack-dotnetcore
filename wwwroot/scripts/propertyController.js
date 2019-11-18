angular.module('postgresSample')
.controller('propertyController', function ($scope, psaService) {
    // Do something with myService,psaService
    //alert('propController');
    //alert(psaService.getList());
    $scope.nodata = true;
  
    $scope.Search = function (address) {
        $('#loadTxt').html("Loading...");
                    setBusyLoaderVisibility(true);

        var latLng;
        geocoder = new google.maps.Geocoder();
        if (geocoder) {
            geocoder.geocode({ address: address }, function (result, status) {
                if (status === google.maps.GeocoderStatus.OK) {
                    latLng = {
                        lat: result[0].geometry.location.lat(),
                        lng: result[0].geometry.location.lng()
                    };

                    psaService.geo.Latitude = latLng.lat;
                    psaService.geo.Longitude = latLng.lng;

                    psaService.getSearchList(psaService)
                  .then(function (res) {
                      console.log(res);
                      $scope.List = res;
                      if ($scope.List.length == 0) {
                          $scope.nodata = true;
                      }
                      else {
                          $scope.nodata = false;
                      }
                      $('#loadTxt').html("");
                      setBusyLoaderVisibility(false);
                  }, function (err) {
                      console.log(err);
                  })
                   
                }
            })
        }
    }

    $scope.GetLatLong = function (address) {
        geocoder = new google.maps.Geocoder();
        if (geocoder) {
            geocoder.geocode({ address : address }, function (result, status) {
                if (status === google.maps.GeocoderStatus.OK) {
                    $scope.latLng = {
                        lat: result[0].geometry.location.lat(),
                        lng: result[0].geometry.location.lng()
                    };
                    $scope.$apply();
                }
            })
        }
    }

    //$scope.CombineAddress = function (address, state, country) {
    //    var addr=[address,state,country];
    //    return addr.join(' ');
    //}

});