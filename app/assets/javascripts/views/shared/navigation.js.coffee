class Visio.Views.NavigationView extends Backbone.View

  template: HAML['shared/navigation']

  initialize: () ->

  events:
    'click .open': 'onClickOpen'
    'change .visio-checkbox input': 'onChangeSelection'

  render: () ->

    parameters = []

    _.each _.values(Visio.Parameters), (hash) ->

      data = Visio.manager.strategy()[hash.plural]()

      parameters.push
        data: data
        hash: hash

    @$el.html @template(
      strategy: Visio.manager.strategy()
      parameters: parameters)

  onChangeSelection: (e) ->
    $target = $(e.currentTarget)

    typeid = $target.val().split(Visio.Constants.SEPARATOR)

    type = typeid[0]
    id = typeid[1]

    if $target.is(':checked')
      Visio.manager.get('selected')[type][id] = true
    else
      delete Visio.manager.get('selected')[type][id]

    Visio.manager.trigger('change:selected')

  onClickOpen: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @open(type)

  open: (type) =>
    $opened = @$el.find('.ui-accordion-content.opened')
    if $opened.attr('data-type') == type
      $opened.toggleClass('opened')
    else
      $opened.removeClass('opened')
      @$el.find(".ui-accordion-content.#{type}").addClass('opened')


