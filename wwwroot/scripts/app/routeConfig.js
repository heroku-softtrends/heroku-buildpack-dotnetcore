var myApp = angular
    .module('postgresSample', ['ngRoute']);
angular.module('postgresSample', ['ui.router']);
myApp.config(function ($routeProvider, $locationProvider, $urlRouterProvider) {
    alert('route');
    if (window.history && window.history.pushState) {
        $locationProvider.html5Mode({
            enabled: true,
            requireBase: false
        }).hashPrefix('!');
        $locationProvider.html5Mode(true).hashPrefix('!');
    }
    $routeProvider.when('/Property/Index', {
        templateUrl: '/Views/Property/Index.cshtml',
        controller: 'propertyController'
    })
    .otherwise({
        redirectTo:'/Property/Index'
    });
   
    $urlRouterProvider.otherwise('/index');
    $urlRouterProvider.rule(function ($injector, $location) {
        var path = $location.url();
        // check url has a slash
        if (path[path.length - 1] === '/' || path.indexOf('/?') > -1) {
            return;
        }

        if (path.indexOf('?') > -1) {
            return path.replace('?', '/?');
        }
        return path + '/';
    });

});
