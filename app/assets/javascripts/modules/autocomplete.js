$(document).on('ready page:load', function() {
  var terms = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/suggest?q=%QUERY',
      wildcard: '%QUERY'
    }
  });

  terms.initialize();

  $('input.search_q').typeahead({
    hint: true,
    highlight: true,
    minLength: 2
  },
  {
    name: 'terms',
    displayKey: 'term',
    source: terms.ttAdapter()
  });
});
