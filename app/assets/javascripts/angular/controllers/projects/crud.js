angular.module('MyApp').controller('NewProjectCtrl', 
  function($scope, $uibModalInstance, $auth, Project, toastr) {
    $scope.isAuthenticated = function() {
      return $auth.userIsAuthenticated();
    };

    $scope.formData = { loadingBoards: false, loadingLists: false };

    $scope.loginWithTrello = function() {
      $auth.authenticate('trello')
        .then(function() {

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

    $scope.projectSelected = function() {
      if ($scope.formData.selectedBoard) {
        $scope.step = 3;

        $scope.formData.loadingLists = true;
        Project.trello_lists($scope.formData.selectedBoard.id).then(function(data) {
          $scope.formData.lists = data;
          $scope.formData.loadingLists = false;
        }, function() {
          $scope.formData.loadingLists = false;
        });
      }
    };

    $scope.todoSelected = function() {
      if ($scope.formData.selectedBoard && $scope.formData.selectedList) {
        var board = $scope.formData.selectedBoard;
        var list = $scope.formData.selectedList;
        var project = new Project();
        project.name = board.name;
        project.description = board.desc;
        project.info = { board_id: board.id,todo_list_id: list.id };
        project.save().then(function(data) {
          $scope.step = 4;
        });
      }
    };

    $scope.getOptionPlaceholder = function(list, loading, placeholderMessage, loadingMessage) {
      return loading ? loadingMessage : placeholderMessage;
    };

    $scope.step = $scope.isAuthenticated() ? 2 : 1;
    if ($scope.step > 1) {
      $scope.loggedSucessfully();
    }
  });