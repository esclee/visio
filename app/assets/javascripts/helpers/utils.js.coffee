Visio.Utils.signin = (login, password) ->
  data =
    remote: true
    commit: "Sign in"
    utf8: "✓"
    user:
      remember_me: 1
      password: password
      login: login

  $.post('/users/sign_in.json', data)


Visio.Utils.signup = (firstname, lastname, login, password, passwordConf, callback) ->
  data =
    remote: true
    commit: "Sign up"
    utf8: "✓"
    user:
      remember_me: 1
      password: password
      password_confirmation: passwordConf
      login: login
      firstname: firstname
      lastname: lastname

  $.post('/users', data, (resp) ->
    console.log resp
    if callback
      callback(resp)
  )

Visio.Utils.signout = (callback) ->

  $.ajax(
    url: '/users/sign_out',
    type: 'DELETE',
    success: (resp) ->
      console.log(resp)
      if callback
        callback(resp)
    error: (resp) ->
      console.log(resp)
      if callback
        callback(resp))

Visio.Utils.flash = ($ele, msg) ->
  $ele.removeClass('flash')

  # Cause a redraw
  $ele[0].offsetWidth = $ele[0].offsetWidth

  $ele.addClass('flash')

  $ele.attr('placeholder', msg)

Visio.Utils.parseTransform = (string) ->
  result =
    translate: [0, 0]
    scale: 1
  return result unless string

  matchTranslate = string.match(/translate\(([0-9\.]+,[ ]*[0-9\.]+)\)/)
  matchScale = string.match(/scale\(([0-9\.]*\.[0-9\.]*)\)/)

  if matchTranslate && matchTranslate[1]
    translate = matchTranslate[1].split(',').map((d) -> return +d )
    result.translate = translate if translate?

  if matchScale && matchScale[1]
    scale = +matchScale[1]
    result.scale = scale if scale?

  return result

Visio.Utils.countToFormatter = (value) ->
  d3.format('d')(value.toFixed(0)) || 0

Visio.Utils.humanMetric = (metric) ->
  if metric == Visio.Algorithms.REPORTED_VALUES.myr
    return 'MYR'
  else if metric == Visio.Algorithms.REPORTED_VALUES.yer
    return 'YER'
  else if metric == Visio.Algorithms.REPORTED_VALUES.baseline
    return 'Baseline'
  else if metric == Visio.Algorithms.GOAL_TYPES.target
    return 'Target'
  else if metric == Visio.Algorithms.GOAL_TYPES.standard
    return 'Standard'
  else if metric == Visio.Algorithms.GOAL_TYPES.compTarget
    return 'Comprehensive Target'
  else if metric == Visio.Algorithms.ALGO_RESULTS.success
    return 'Acceptable'
  else if metric == Visio.Algorithms.ALGO_RESULTS.ok
    return 'Not Acceptable'
  else if metric == Visio.Algorithms.ALGO_RESULTS.fail
    return 'Critical'
  else if metric == Visio.Algorithms.STATUS.missing
    return 'Non-reported'
  else if metric == Visio.Algorithms.ALGO_RESULTS.high
    return 'Met Target'
  else if metric == Visio.Algorithms.ALGO_RESULTS.medium
    return 'Approaching Target'
  else if metric == Visio.Algorithms.ALGO_RESULTS.low
    return 'Below Target'
  else if metric == Visio.Algorithms.STATUS.missing
    return 'Not Reported'
  else
    return metric

Visio.Utils.nl2br = (string) ->
  string.replace(/\n/g, '<br />')

Visio.Utils.space2nbsp = (string) ->
  string.replace(/\ /g, '&nbsp;')

Visio.Utils.stringToCssClass = (string) ->
  return string unless string
  string.replace(/\ /g, '-')

Visio.Utils.generateOverviewUrl = ->
  [Visio.router.moduleView.id,
   Visio.manager.year(),
   Visio.manager.get('aggregation_type'),
   Visio.manager.get('reported_type')].join '/'

Visio.Utils.parameterByPlural = (plural) ->
  for parameter, hash of Visio.Parameters
    return hash if hash.plural == plural
  null

Visio.Utils.parameterBySingular = (singular) ->
  for parameter, hash of Visio.Parameters
    return hash if hash.singular == singular
  null

Visio.Utils.inlineCssStyles = ($ele) ->
  $ele.css css($ele)

Visio.Utils.recursiveInlineCssStyles = ($ele) ->
  Visio.Utils.inlineCssStyles $ele
  $ele.children().each (idx, ele) ->
    Visio.Utils.recursiveInlineCssStyles $(ele) unless _.isEmpty($(ele).children())
