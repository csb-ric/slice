# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  $("#{filter_element} .datepicker").datepicker('remove')
  $("#{filter_element} .datepicker").datepicker( autoclose: true )

  $("#{filter_element} .datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))

    catch error
      # Nothing
  )


  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $this.data('variable-id') + '/typeahead' + '?query=%QUERY' + "&sheet_authentication_token=#{($('#sheet_authentication_token').val() || '')}"
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  checkAllRanges()
  $("span[rel~=tooltip], label[rel~=tooltip]").tooltip( trigger: 'hover' )
  $("span[rel~=popover], label[rel~=popover]").popover( trigger: 'hover' )
  loadAffix()
  $( ".grid_sortable" ).sortable({ axis: "y" })

@evaluateBranchingLogic = () ->
  $('[data-object~="evaluate-branching-logic"]').each( (index, element) ->
    if $(element).data('branching-logic') == ""
      branching_logic_result = true
    else
      try
        branching_logic_result = eval($(element).data('branching-logic'))
      catch error
        branching_logic_result = true

    if branching_logic_result
      # $(element).css('background', "#ccc")
    else
      $(element).hide()
      # $(element).css('background', "#0f0")
  )
  loadAffix()

@loadAffix = () ->
  $(document.body).scrollspy(
    target: '.bs-sidebar'
    offset: $('.navbar').outerHeight(true) + 10
  )

  $sideBar = $('.bs-sidebar')

  $sideBar.affix(
    offset:
      top: () ->
        offsetTop      = $('#main-bar').offset().top
        sideBarMargin  = parseInt($sideBar.children(0).css('margin-top'), 10)
        navOuterHeight = $('.navbar-fixed-top').height()
        return (this.top = offsetTop - navOuterHeight - sideBarMargin)
      bottom: () ->
        return ( this.bottom = $(document.body).outerHeight(true) - $('#main-bar').offset().top - $('#main-bar').outerHeight(true) )
  )
  $('[data-spy="scroll"]').each( () ->
    $spy = $(this).scrollspy('refresh')
  )

@sheetsReady = () ->
  $('#sheet_subject_id').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $("#sheet_subject_id").data('local')
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong> {{acrostic}}</p>'
      engine: Hogan
    )
  )
  initializeSheet()

$(document)
  .on('click', '[data-object~="export"]', () ->
    url = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
    if $(this).data('page') == 'blank'
      window.open(url)
    else
      window.location = url
    false
  )
  .on('click', "[data-link]", (e) ->
    if $(e.target).is('a')
      # Do nothing, propagate standard behavior
    else if nonStandardClick(e)
      window.open($(this).data("link"))
      return false
    else
      Turbolinks.visit($(this).data("link"))
  )
  .on('click', '[data-object~="export-data"]', () ->
    $('[data-dismiss~=alert]').click()
    form = $(this).data('target')
    $.get($(form).attr("action"), $(form).serialize() + '&export=1', null, "script")
    $(this).attr('disabled', 'disabled')
    false
  )
  .on('click', '[data-object~="sidebar-link"]', () ->
    $(this).blur()
  )
  .on('change', '[data-object~="set-subject-schedule-event"]', () ->
    subject_schedule_id = $(this).val().split('-')[0]
    event_id = $(this).val().split('-')[1]
    $("#sheet_subject_schedule_id").val(subject_schedule_id)
    $("#sheet_event_id").val(event_id)
  )
  .on('change', '#sheet_design_id', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/designs/selection', $(this).serialize() + '&' + $("#sheet_subject_id").serialize(), null, "script")
    false
  )
  .on('typeahead:selected', "#sheet_subject_id", (event, datum) ->
    $(this).val(datum['value'])
    $('#sheet_subject_acrostic').val(datum['acrostic'])
    $('#site_id').val(datum['site_id'])
  )
