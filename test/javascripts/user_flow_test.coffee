module 'Signup',
  setup: () ->
    stop()
    $.ajax(
      url: '/test/user_setup'
      type: 'POST'
      success: () ->
        start()
    )
  teardown: () ->
    stop()
    $.ajax(
      url: '/test/user_teardown'
      type: 'POST'
      success: () ->
        start()
    )

asyncTest('Basic user creation via ajax', () =>
  Visio.Utils.signup 'r@r.com', '12345678', '12345678', (resp) ->
    ok(resp.success)
    start()
)

asyncTest('Test basic sign in via ajax', () =>
  Visio.Utils.signin('test@test.com', 'TeStInG!',(resp) =>
    ok(resp.success)
    start())
)

asyncTest('Test basic sign out via ajax', () =>
  Visio.Utils.signin('test@test.com', 'TeStInG!',(resp) =>
    ok(resp.success)
    Visio.Utils.signout((resp) ->
      console.log(resp)
      start()
      )
    )
)