angular.module('postgresSample').service('psaService', function ($scope,$q,$http) {

    var property = this;

    property.getSearchList = function (property) {
        var defer = $q.defer();

        $http.post('Property/GetSearchList', property)
        .success(function (res) {
            defer.resolve(res);
        })
        .error(function (err, status) {
            defer.reject(err)
        })
        return defer.promise;
    }

});