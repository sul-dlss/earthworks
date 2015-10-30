// Inspired by and modified from http://railsapps.github.io/rails-google-analytics.html

GoogleAnalytics = (function() {
  function GoogleAnalytics() {}

  GoogleAnalytics.load = function() {
    var firstScript, ga;
    window._gaq = [];
    GoogleAnalytics.analyticsId = GoogleAnalytics.getAnalyticsId();
    window._gaq.push(['_setAccount', GoogleAnalytics.analyticsId]);
    ga = document.createElement('script');
    ga.type = 'text/javascript';
    ga.async = true;
    ga.src = ('https:' === document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    firstScript = document.getElementsByTagName('script')[0];
    firstScript.parentNode.insertBefore(ga, firstScript);
  };

  GoogleAnalytics.trackPageview = function(url) {
    if (!GoogleAnalytics.isLocalRequest()) {
      if (url) {
        window._gaq.push(['_trackPageview', url]);
      } else {
        window._gaq.push(['_trackPageview']);
      }
      return window._gaq.push(['_trackPageLoadTime']);
    }
  };

  GoogleAnalytics.isLocalRequest = function() {
    return GoogleAnalytics.documentDomainIncludes('local');
  };

  GoogleAnalytics.documentDomainIncludes = function(str) {
    return document.domain.indexOf(str) !== -1;
  };

  GoogleAnalytics.getAnalyticsId = function() {
    return $('[data-analytics-id]').data('analytics-id');
  };

  return GoogleAnalytics;

})();

Blacklight.onLoad(function() {
  GoogleAnalytics.load();
  if (GoogleAnalytics.analyticsId) {
    GoogleAnalytics.trackPageview();
  }

  // Log spatial search events

  // Map Moved
  History.Adapter.bind(window, 'statechange', function(e) {
    var state = History.getState();
    window._gaq.push(['_trackEvent', 'Spatial Search', 'Map Moved', state.url]);
  });

  // Initiate search in an area
  $('.leaflet-control.search-control a.btn-primary').on('click', function(e) {
    window._gaq.push(['_trackEvent', 'Spatial Search', 'Search Here', e.currentTarget.baseURI]);
  });

  // Log download clicks
  $(document).on('click', '[data-download="trigger"]', function(e) {
    var data = $(e.target).data();
    window._gaq.push(['_trackEvent', 'Download', data.downloadId, data.downloadType]);
  });

  // Log failed download
  $(document).on('DOMNodeInserted', function(e) {
    var data = $('[data-download="error"]').data();
    if (data) {
      window._gaq.push(['_trackEvent', 'Failed Download', data.downloadId, data.downloadType]);
    }
  });

  // Log Open in CartoDB Clicks
  $(document).on('click', 'li.exports a:contains("Open in CartoDB")', function(e) {
    window._gaq.push(['_trackEvent', 'Open in CartoDB', window.location.pathname.replace('/catalog/', '')]);
  });
});
