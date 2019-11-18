

//angular.module('postgresSample')
//        .controller('propertyController', propertyController);

//propertyController.$inject = ['psaService'];

//function propertyController($location, $scope, $http, psaService) {
//    alert('prop');

//    $scope.SearchList = function (property) {
//        psaService.getSearchList(property)
//        .then(function (res) {
//            $scope.List = '';
//        }, function (err) {

//        })
//    }

//};
angular.module('postgresSample')
.controller('propertyController', function ($scope, psaService) {

    alert('propController');
    $scope.SearchList = function (property) {
                psaService.getSearchList(property)
                .then(function (res) {
                    $scope.List = '';
                }, function (err) {

                })
            }

})