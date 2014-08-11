fs = require('fs')

parseSExp = (sourceCode) ->
  if sourceCode.length > 0 and sourceCode[0] == "("
    sExp = []
    remaining = strip(sourceCode[1..])
    while remaining[0] isnt ")"
      [success, result, remaining] = any([parseName, parseNumber, parseSExp])(remaining)
      if success
        sExp.push(result)
      else
        return [false, null, sourceCode]
      success   = false
      result    = null
      remaining = strip(remaining)
    [true, sExp, remaining[1..]]
  else
    [false, null, sourceCode]

parseName = (sourceCode) ->
  name = sourceCode.match(/^[abcdefghijklmnopqrstuvwxyz+]+/)
  if name
    [true, name[0], strip(sourceCode[name[0].length..])]
  else
    [false, null, sourceCode]

parseNumber = (sourceCode) ->
  number = sourceCode.match(/^\d+/)
  if number
    [true, parseInt(number[0], 10), strip(sourceCode[number[0].length..])]
  else
    [false, null, sourceCode]

any = (trials) ->
  (sourceCode) ->
    success   = false
    result    = null
    remaining = sourceCode
    for trial in trials
      if success == false
        [success, result, remaining] = trial(sourceCode)
    [success, result, remaining]


strip = (string) -> string.replace(/^\s+|\s+$/g, '')

sourceCode     = fs.readFileSync("input", { encoding: "utf8" })
[success, ast, remaining] = parseSExp(sourceCode)

if not success
  throw "Invalid program"
else
  console.log(ast)

lookUp = (variable, env) ->
  value = env.bindings[variable]
  if value == undefined
    if env.parent
      lookUp(variable, env.parent)
    else
      throw "Unbound variable '#{variable}'"
  else
    if typeof value == "string"
      lookUp(value, env)
    else
      value

interpret = (thing, env) ->
  if typeof thing == "object"
    if thing[0] == "let"
      newEnv = { parent: env, bindings: {}}
      remaining = thing[1]
      while remaining.length > 0
        if remaining.length == 1
          throw "Binding without a value '#{remaining[0]}'"
        else
          newEnv.bindings[remaining[0]] = interpret(remaining[1], newEnv)
          remaining = remaining[2..]
      for x in thing[2..]
        interpret(x, newEnv)
    else if thing[0] == "fn"
      varList = thing[1]
      body    = thing[2]
      (args) ->
        localBindings = { parent: env, bindings: {} }
        c = 0
        for v in varList
          localBindings.bindings[v] = args[c]
          c = c + 1
        interpret(body, localBindings)
    else
      fn = interpret(thing[0], env)
      args = (interpret(a, env) for a in thing[1..])
      fn(args)
  else if typeof thing == "number"
    thing
  else if typeof thing == "string"
    lookUp(thing, env)

globalEnv = { parent: null, bindings: {
  "+": (as) ->
    result = 0
    for a in as
      result = result + a
    result
  "print": (as) -> console.log(a) for a in as
}}

interpret(ast, globalEnv)
