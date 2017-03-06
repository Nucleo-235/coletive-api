angular.module('MyApp').controller('NewProjectCtrl', 
  ['$scope', '$rootScope', '$auth', 'Project', 'toastr', function($scope, $rootScope, $auth, Project, toastr) {
    $rootScope.hasActions = true;
    $rootScope.back = function() {
      $scope.step = $scope.step - 1;
    };

    $scope.isAuthenticated = function() {
      return $auth.userIsAuthenticated();
    };

    $scope.formData = { loadingBoards: false, loadingLists: false };

    $scope.loginWithTrello = function() {
      $auth.authenticate('trello')
        .then(function() {
          $scope.loggedSucessfully();
        })
        .catch(function(resp) {
          console.log(resp);
          //logOrRegisterWithUUID();
        });
    };

    $scope.loggedSucessfully = function() {
      $scope.step = 2;

      $scope.formData.loadingBoards = true;
      Project.trello_boards().then(function(data) {
        $scope.formData.boards = data;
        $scope.formData.loadingBoards = false;
      }, function() {
        $scope.formData.loadingBoards = false;
      });
    };

    $scope.canMoveFromStep2 = function() {
      return $scope.formData.selectedBoard;
    }

    $scope.canMoveFromStep3 = function() {
      return $scope.formData.selectedList;
    }

    $scope.canMoveFromStep4 = function() {
      return $scope.formData.description && $scope.formData.description.length > 0;
    }

    $scope.projectSelected = function() {
      if ($scope.canMoveFromStep2()) {
        $scope.step = 3;
        $scope.formData.description = $scope.formData.selectedBoard.desc;

        $scope.formData.loadingLists = true;
        Project.trello_lists($scope.formData.selectedBoard.id).then(function(data) {
          if (data && data.length > 0) {
            $scope.formData.selectedList = data.first_or_null(function(item, index) {
              var lower_name = item.name.toLowerCase();
              return lower_name == 'todo' || lower_name == 'to-do' || lower_name == 'to do' || lower_name == 'a fazer' || lower_name == 'pendente';
            });
            if ($scope.formData.selectedList)
              $scope.selectedListIndex = data.indexOf($scope.formData.selectedList);
            else
              $scope.selectedListIndex = 0;
          }
          $scope.formData.lists = data;
          $scope.formData.loadingLists = false;
        }, function() {
          $scope.formData.loadingLists = false;
        });
      }
    };

    $scope.todoSelected = function() {
      if ($scope.canMoveFromStep2() && $scope.canMoveFromStep3()) {
        $scope.step = 4;
      }
    }

    $scope.descriptionFilled = function() {
      if ($scope.canMoveFromStep2() && $scope.canMoveFromStep3() && $scope.canMoveFromStep4()) {
        var board = $scope.formData.selectedBoard;
        var list = $scope.formData.selectedList;
        var project = new Project();
        project.name = board.name;
        project.description = $scope.formData.description;
        project.extra_info = $scope.formData.extra_info;
        project.info = { board_id: board.id,todo_list_id: list.id };
        project.save().then(function(data) {
          $scope.step = 5;
        }, function(error) {
          console.log(error);
        });
      }
    };

    function checkStepTitle() {
      if ($scope.step == 1) {
        $rootScope.pageTitle = false;
        $rootScope.hasBack = false;
      } else {
        $rootScope.hasBack = true;
        if ($scope.step == 2) {
          $rootScope.pageTitle = 'ESCOLHER O PROJETO';
        } else if ($scope.step == 3) {
          $rootScope.pageTitle = 'ESCOLHER A LISTA DE TAREFAS';
        } else if ($scope.step == 4) {
          $rootScope.pageTitle = 'DESCRIÇÃO E INFORMAÇÕES';
        } else {
          $rootScope.pageTitle = false;
        }
      }
    }

    $scope.$watch('step', checkStepTitle);

    $scope.getOptionPlaceholder = function(list, loading, placeholderMessage, loadingMessage) {
      return loading ? loadingMessage : placeholderMessage;
    };

    $scope.step = $scope.isAuthenticated() ? 2 : 1;
    if ($scope.step > 1) {
      $scope.loggedSucessfully();
    }
    checkStepTitle();

    $rootScope.$on('auth:login-success', function(ev, user) {
      if ($scope.step == 1) {
        $scope.loggedSucessfully();
      }
    });

    $rootScope.$on('auth:validation-success', function(ev, user) {
      if ($scope.step == 1) {
        $scope.loggedSucessfully();
      }
    });
  }]);