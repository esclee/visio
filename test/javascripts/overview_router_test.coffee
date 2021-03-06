module 'Overview Router',
  setup: ->
    stop()
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager({
      strategy_id: 1
      strategies: new Visio.Collections.Strategy([{ id: 1, operation_ids: {20:true} }, { id: 2 }]),
      ready: ->
        Visio.router = new Visio.Routers.OverviewRouter()
        Backbone.history.start({ silent: true}) unless Backbone.History.started
        start()

    })
    Visio.manager.set 'dashboard', Visio.manager.strategy()

    models = [{ id: 20 }, { id: 'abc-efg' }]
    sinon.stub $, 'get', (url, options) ->
      return { new: [{ id: 20 }, { id: 'abc-efg' }], updated: [], deleted: [] }

    @server = sinon.fakeServer.create()
    @server.respondWith 'GET', /.*/, [200, {'Content-Type': 'application/json'}, JSON.stringify(models)]

  teardown: ->
    Visio.manager.get('db').clear()
    $.get.restore()
    @server.restore()


asyncTest 'setup', ->

  Visio.router.setup().done( ->
    ok Visio.manager.get('setup'), 'Should be setup'
    # subtract 2 because we call fetch on Strategy Objective and we don't fetch operations
    strictEqual $.get.callCount, _.keys(Visio.Parameters).length + _.keys(Visio.Syncables).length - 2
    return Visio.router.setup()
  ).done ->
    ok Visio.manager.get('setup'), 'Should be setup'
    strictEqual $.get.callCount,
      _.keys(Visio.Parameters).length + _.keys(Visio.Syncables).length - 2,
      'Should not fetch again after setup'
    start()

  @server.respond()


asyncTest 'figure', ->

  Visio.router.setup().done ->
    Visio.router.figure 'absy', 2013, Visio.Parameters.GOALS.plural, Visio.Algorithms.REPORTED_VALUES.yer

    ok Visio.router.moduleView instanceof Visio.Views.AbsyView
    strictEqual Visio.manager.year(), 2013
    strictEqual Visio.manager.get('aggregation_type'), Visio.Parameters.GOALS.plural
    strictEqual Visio.manager.get('reported_type'), Visio.Algorithms.REPORTED_VALUES.yer
    start()

  @server.respond()
