angular.module('MyApp')
  .factory('Project', ['$resource', '$auth', 'railsResourceFactory', 'config', 
    function($resource, $auth, railsResourceFactory, config) {
      var resource = railsResourceFactory({
        url: config.API_URL + '/projects', 
        name: 'project',
        interceptors: ['setPagingHeadersInterceptor']
      });

      return resource;
  }]);