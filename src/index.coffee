app = angular.module 'unwrap', []

app.controller 'DemoCtrl', [
  '$scope'
  '$rootScope'
  '$q'
  '$timeout'
  'unwrap'
(
  $scope
  $rootScope
  $q
  $timeout
  unwrap
) ->
  d1 = $q.defer()
  $timeout (-> d1.resolve v: 'object resolved through timeout'), 5000
  d2 = $q.defer()
  $timeout (-> d2.resolve ['array', 'resolved', 'after', 'timeout']), 5000
  d3 = $q.defer()
  d3.reject "throw"

  $scope.demo =
    instantObject: unwrap {}, $q.when v: "instant object"
    rejectedObject: unwrap {}, $q.reject new Error "error"
    deferredObject: unwrap {}, d1.promise
    instantArray: unwrap [], $q.when [1,2,3]
    rejectedArray: unwrap [], $q.reject "rejected"
    deferredArray: unwrap [], d2.promise
    rescued: unwrap {}, d3.promise.catch (err) ->
      return v: "caught and rescued!"

  # Option to listen to rejection events on $rootScope
  $rootScope.$on 'unwrap:rejected', (event, args) ->
    console.log "unwrap:rejected event", args

]