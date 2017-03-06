angular.module('rails').factory('ProjectSerializer', function (railsSerializer) {
    return railsSerializer(function () {
        this.nestedAttribute('info');
    });
});

angular.module('MyApp')
  .factory('Project', ['$resource', '$auth', 'ProjectSerializer', 'railsResourceFactory', 'config', 
    function($resource, $auth, ProjectSerializer, railsResourceFactory, config) {
      var resource = railsResourceFactory({
        url: config.API_URL + '/projects', 
        name: 'project',
        serializer: 'ProjectSerializer',
        interceptors: ['setPagingHeadersInterceptor']
      });

      resource.trello_boards = function(params) {
        return resource.$get(resource.$url('trello_boards'), params);
      };

      resource.trello_lists = function(board_id, params) {
        if (!params) params = {};
        params['board_id'] = board_id;
        return resource.$get(resource.$url('trello_lists'), params);
      };

      resource.prototype.fullUrl = function() {
        return config.VIEW_URL + '/#project/' + this.slug;
      };

      return resource;
  }]);