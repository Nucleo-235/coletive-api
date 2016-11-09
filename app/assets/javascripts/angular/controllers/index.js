angular.module('MyApp')
  .controller('IndexCtrl', function($scope, $rootScope, $state, $auth, $q) {
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

    // var isMob = window.cordova !== undefined;
    // if (isMob)
    //   document.addEventListener("deviceready", validate, false);
    // else
    //   validate();
  });
