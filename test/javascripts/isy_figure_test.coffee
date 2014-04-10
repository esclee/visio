module 'ISY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Isy
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100

    @data = new Visio.Collections.IndicatorDatum([
        {
          id: 'ben'
          is_performance: false
          baseline: 0
          myr: 10
          yer: 20
          imp_target: 50
          standard: 50
        },
        {
          id: 'jeff'
          is_performance: true
          baseline: 0
          myr: 20
          yer: 20
          imp_target: 50
          standard: 50
        },
        {
          id: 'lisa'
          is_performance: true
          baseline: 0
          myr: 30
          yer: 20
          imp_target: 50
          standard: 50
        }
      ])

test 'filtered', ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
    },
    {
      id: 'jeff'
      is_performance: true
    },
    {
      id: 'lisa'
      is_performance: true
    }
  ])

  @figure.isPerformanceFn true
  filtered = @figure.filtered data
  strictEqual filtered.length, 2


test 'data', ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
    },
    {
      id: 'jeff'
      is_performance: true
    },
    {
      id: 'lisa'
      is_performance: true
    }
  ])

  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

  @figure.isPerformanceFn false
  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

  @figure.isPerformanceFn(true)
  @figure.collectionFn data
  strictEqual @figure.collectionFn().length, 3
  ok @figure.collectionFn() instanceof Visio.Collections.IndicatorDatum

test 'render', ->

  @figure.isPerformanceFn false
  @figure.collectionFn @data
  @figure.render()

  ok @figure.$el.find('.box').length, 1
  ok @figure.$el.find('.box line').length, 1

test 'sort', ->
  @figure.sortAttribute = Visio.ProgressTypes.BASELINE_MYR

  sorted = @figure.filtered @data
  strictEqual sorted[0].id, 'lisa'
  strictEqual sorted[1].id, 'jeff'