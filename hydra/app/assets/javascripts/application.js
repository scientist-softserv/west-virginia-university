// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

// Rails or Hydra Requirements
// -----------------------------------------------------
//= require jquery3

// Required by Blacklight Advance Search
// -----------------------------------------------------
//= require 'blacklight_advanced_search'
//= require advanced_search_additional_fields

//= require jquery_ujs

//= require tether

// Required by Blacklight
// -----------------------------------------------------
//= require popper
// Twitter Typeahead for autocomplete
//= require twitter/typeahead
//= require bootstrap
//= require blacklight/blacklight

// Required by Bulkrax
// -----------------------------------------------------
//= require datatables
//= require bulkrax/application

// CUSTOM COLLECTION JS
// -----------------------------------------------------
//= require partials/equal_heights
//= require partials/facets
//= require partials/toggles
//= require partials/smooth_scroll
//= require partials/cookie_modal
//= require partials/nav_toggles
//= require partials/toggle_required


// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'
