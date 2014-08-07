###*
* Utility used to unwrap promises, allowing them to be assigned on a scope
* from the start without having to re-assign them once the promise resolves.
* This only works for values of type array or object, since those are the only
* variables passed by reference in JavaScript.
*
* The initial value provided as the first parameter will be mutated into the
* value resolved by the promise.
*
* A reusable function may be provided in place of the promise. It should return
* a promise which then resolves to the final value. unwrap can then create a
* re-usable function on the value object which can called to reload the value.
* The third parameter is required for this, specifying the name of the reload
* function.
*
* @param value {Array|Object} Base object to unwrap unto.
* @param promiseOrFunction {P{Array|Object} | Function} Promise or function returning promise.
* @param reloadFnName {String|void} Reload function name defined on the value object (optional).
* @return {Array|object} The initial value object.
###
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
  return (value, promiseOrFunction, reloadFnName) ->
    unless arguments.length > 1
      throw new Error "unwrap: Initial value and function/promise required " +
        "but missing one (propably initial value)"

    valueType = typeOf value
    unless valueType in ['Array', 'Object']
      error = "unwrap: Value must be an array or object (was #{valueType})"
      console.error error, value
      throw new Error error

    execute = (obj) ->
      obj = obj.$promise if '$promise' of obj
      unless typeof obj.then is 'function'
        error = "unwrap: Provided object doesn't seem to be a promise"
        console.error error, obj
        throw new Error error

      # Hook into promise chain
      return obj.then (data) ->
        clear[valueType](value)
        dataType = typeOf(data)
        if dataType is valueType
          repopulate[valueType](value, data)
        else
          $rootScope.$emit 'unwrap:typeMismatch', {value, data, dataType, valueType}
        return value
      , (reason) ->
        $rootScope.$emit 'unwrap:rejected', {reason, value, valueType}
        clear[valueType](value)
        return

    # Expose a reload function on the value object?
    if typeOf(promiseOrFunction) is 'Function'
      execute promiseOrFunction()
      if typeOf(reloadFnName) is 'String'
        value[reloadFnName] = -> execute promiseOrFunction()
    else
      execute promiseOrFunction

    return value
]
