class Row
  constructor: (@lineno, row) ->
    @cells = @__parseRow(row)

  widths: ->
    @cells.map (cell) => cell.length

  print: (indent, widths = @widths()) ->
    line = indent
    @cells.forEach (el, idx) =>
      line += "| "
      line += @__rightPad(el, widths[idx])
      line += " "
    line + "|"

  __parseRow: (row) ->
    row.trim().split('|')
      .map((cell) => cell.trim())
      .slice(1, -1)

  __rightPad: (string, length) ->
    len = length - string.length
    if len <= 0
      return string
    else
      pad = Array.apply(null, length: len).map(-> ' ').join('')
      string + pad

class Table
  constructor: ->
    @indent = null
    @rows = []

  addRow: (lineno, row) ->
    @indent ?= row.match(/^(\s*)\|/)[1]
    @rows.push(new Row(lineno, row))

  toString: ->
    widths = @__columnWidths()
    lines = @rows
      .map (row) => row.print(@indent, widths)
      .join("\n")

  applyToBuffer: (buffer) ->
    widths = @__columnWidths()
    lines = @rows.forEach (row) =>
      line = row.print(@indent, widths)
      range = buffer.rangeForRow(row.lineno, false)
      buffer.setTextInRange(range, line)

  __columnWidths: ->
    @rows
      .map((row) => row.widths())
      .reduce (previous, current) =>
        previous.map (el, idx) =>
          if el > current[idx] then el else current[idx]

module.exports =
  class Cucumber
    constructor: (@editor) ->

    alignTableCells: ->
      buffer = @editor.getBuffer()
      tables = @__getTables()
      buffer.transact ->
        tables.forEach (t, idx) ->
          t.applyToBuffer(buffer)

    __getTables: ->
      previous_line = ""
      current_table = null
      tables = []
      lineno = 0
      for line in @editor.getBuffer().getLines()
        if @__isTableRow(line)
          if @__isTableRow(previous_line)
            current_table.addRow(lineno, line)
          else
            current_table = new Table()
            tables.push(current_table)
            current_table.addRow(lineno, line)
        lineno += 1
        previous_line = line
      tables

    __isTableRow: (line) ->
      line.match(/^\s*\|/) != null
