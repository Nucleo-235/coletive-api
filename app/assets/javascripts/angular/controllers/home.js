angular.module('MyApp')
  .controller('HomeCtrl', function($scope, $rootScope, $state, $auth, $q, Project, $uibModal) {
    $rootScope.hasActions = false;

    function successLogged(data) {
      console.log('logged')
    };

    $scope.loginWithTrello = function() {
      $auth.authenticate('trello')
        .then(successLogged)
        .catch(function(resp) {
          console.log(resp);
          //logOrRegisterWithUUID();
        });
    };

    $scope.isAuthenticated = function() {
      return $auth.userIsAuthenticated();
    };

    function validate() {
      $auth.validateUser().then(successLogged, function(result) {
        // deixa a pessoa fazer seu próprio login
        // setTimeout(logOrRegisterWithUUID, 100);

        return result;
      });
    }

    function reloadProjects() {
      Project.query().then(function(data) {
        $scope.projects = data;
      });
    }
    reloadProjects();

    $scope.newProject = function() {
      $state.go('new_project');
    }

    // var isMob = window.cordova !== undefined;
    // if (isMob)
    //   document.addEventListener("deviceready", validate, false);
    // else
    //   validate();
  });
