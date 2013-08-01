loaded = []

$('iframe.chart').on('load', ->
  return if loaded.indexOf(this) > -1
  loaded.push(this)
  chart = $(this)
  chart.parents('.item').removeClass('loading')
)