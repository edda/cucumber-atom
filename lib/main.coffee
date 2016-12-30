Cucumber = require('./cucumber')
{CompositeDisposable} = require('atom')

module.exports =
  subscriptions: null
  activate: ->
    @subscriptions = new CompositeDisposable()
    @subscriptions.add(
      atom.commands.add('atom-workspace', 'cucumber:align-table-cells': => @alignTableCells())
    )

  deactivate: ->
    @subscriptions.dispose()

  alignTableCells: ->
    cucumber = new Cucumber(atom.workspace.getActivePaneItem())
    cucumber.alignTableCells()
