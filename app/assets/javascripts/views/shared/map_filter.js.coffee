class Visio.Views.MapFilterView extends Backbone.View

  className: 'map-filters'

  filters: ['Zoom', 'Strategy', 'Year']

  initialize: (options) ->

    @render()

  render: () ->
    _.each @filters, (filter) =>
      @filterViews = new Visio.Views["#{filter}FilterView"]

      @$el.append @filterViews.el

    $('.map-container').prepend @el
    @
