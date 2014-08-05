app.factory 'unwrap', ['$rootScope', ($rootScope) ->
  typeOf = (x) -> {}.toString.call(x).slice(8, -1)

  clear =
    Array: (value) -> value.length = 0
    Object: (value) ->
      for own key of value
        delete value[key]
      return

  repopulate =
    Array: (value, src) ->
      for row in src
        value.push row
      return
    Object: (value, src) ->
      for key, v of src
        value[key] = v
      return

  # Unwrap function
  return (value, fn, reloadFnName) ->
    valueType = typeOf value
    unless valueType in ['Array', 'Object']
      error = "unwrap: Value must be an array or object (was #{valueType})"
      console.error error, value
      throw new Error error

    # Locate .then method
    thenFn = if '$promise' of fn
      fn.$promise.then
    else if 'then' of fn
      fn.then
    else
      error = "unwrap: Provided object doesn't seem to be a promise"
      console.error error, fn
      throw new Error error

    # Hook it up
    thenFn (data) ->
      clear[valueType](value)
      dataType = typeOf(data)
      if dataType is valueType
        repopulate[valueType](value, data)
      else
        $rootScope.$emit 'unwrap:typeMismatch', {value, data, dataType, valueType}
    , (reason) ->
      $rootScope.$emit 'unwrap:rejected', {reason, value, valueType}
      clear[valueType](value)

    # Expose a reload function on the value object?
    if typeOf(fn) is 'Function' and typeOf(reloadFnName) is 'String'
      value[reloadFnName] = fn.bind fn

    return value
]
