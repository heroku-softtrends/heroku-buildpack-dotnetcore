
var app = angular.module('postgresSample');
app.factory('psaService', function ($http, $q) {

    //alert('psaService');
    var property = {};
    property.geo = {
        Latitude: '',
        Longitude: ''
    };

    property.getList = function () {
        return "success";
    }
    property.getSearchList = function (property) {

        var defer = $q.defer();

        $http.post('Property/GetSearchList?latitude1=' + property.geo.Latitude + '&latitude2=' + property.geo.Longitude)
        .success(function (res) {
            defer.resolve(res);
        })
        .error(function (err, status) {
            defer.reject(err)
        });
        return defer.promise;
    }
    return property;

});