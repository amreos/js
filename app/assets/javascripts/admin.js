$(document).ready(function(){
  
  $(this).bind('keydown', 'alt+ctrl+t', function(){
    $(".modal").remove();
    $('#flash').remove();
    $("#content").after("<div class='modal' title='Loading'></div>");
    $("header#banner").after('<div id="flash"><div id="loading">Loading...</div></div>');
    $.get('/manage/tasks/new');
    centerFlashMessage();    
  });
  
  var new_height = ($(window).height() * 0.54);
  $("aside section.list").css({'height' : new_height + "px"});
  
  function centerFlashMessage() {
    var flashMargin = ($(window).width() - $("#flash").width()) / 2; 
    $("#flash").css({'left' : flashMargin+"px"});
  }
  
  /**
	* @author Remy Sharp
	* @url http://remysharp.com/2007/01/25/jquery-tutorial-text-box-hints/
	*/
		
	$.fn.hint = function (blurClass) {
	  if (!blurClass) { 
	    blurClass = 'blur';
	  }

	  return this.each(function () {
	    // get jQuery version of 'this'
	    var $input = $(this),

	    // capture the rest of the variable to allow for reuse
	      title = $input.attr('title')

	    function remove() {
	      if ($input.val() === title && $input.hasClass(blurClass)) {
	        $input.val('').removeClass(blurClass);
	      }
	    }

	    // only apply logic if the element has the attribute
	    if (title) { 
	      // on blur, set value to title attr if text is blank
	      $input.blur(function () {
	        if (this.value === '') {
	          $input.val(title).addClass(blurClass);
	        }
	      }).focus(remove).blur(); // now change all inputs to title
	    }
	  });
	};
	
	$(function(){ 
	 // search over label
		$('#quickSearch').hint();
	});
  
  //extends textchange functionality to add to multiple objects  
  $.fn.count_down = function(options){    
    //extend defaults with new options
    var opts = $.extend({}, $.fn.count_down.defaults, options);
    
    return this.bind('textchange', function (event, previousText){
      var el = $(this);
      var parent = el.parents(".item");  
      //get vars or defaults
      var d = opts;
      var count_display = parent.find('span.charactersLeft');
      var text_length = d.max_length - parseInt($(this).val().length);
      
      if ( text_length < 0 ) {
        $(count_display).addClass('lengthError');
      } else if ( text_length > 0 ) {
        $(count_display).removeClass('lengthError');
      }
      $(count_display).html( text_length );
      
    });
  };
  
  $.fn.setup_count = function(options) {
    var opts = $.extend({}, $.fn.count_down.defaults, options);
       
     return this.each(function(){
       var el = $(this);
       var parent = el.parents(".item");  
       var d = opts;
       var count_display = parent.find('span.charactersLeft');
       var text_length = d.max_length - parseInt($(this).val().length);
     
       if ( text_length < 0 ) {
         $(count_display).addClass('lengthError');
       } else if ( text_length > 0 ) {
         $(count_display).removeClass('lengthError');
       }
       $(count_display).html( text_length );
       
       if ( parent.find("span.error_message.textarea").length ) {
         count_display.css("bottom", "54px");
       }
     });  
  };
    
  $.fn.count_down.defaults = {
    max_length: 1000
  };

  if ($("form #employee_bio").length) {
      $('form .item textarea#employee_bio').setup_count({max_length: 820});
      $("form .item textarea#employee_bio").count_down({max_length: 820});
      
      $('form .item textarea:not("#employee_bio")').setup_count();
      $('form .item textarea:not("#employee_bio")').count_down();
      
  } else if ($("form #job_description").length) {
      $('form .item textarea#job_description').setup_count({max_length: 820});
      $("form .item textarea#job_description").count_down({max_length: 820});
      
      $('form .item textarea#job_summary').setup_count({max_length: 200});
      $("form .item textarea#job_summary").count_down({max_length: 200});

      $('form .item textarea:not("#job_description, #job_summary")').setup_count();
      $('form .item textarea:not("#job_description, #job_summary")').count_down();

  } else {
    $("form .item textarea").setup_count();
    $("form .item textarea").count_down();
  }
  
  $('#editJobNumber').click(function(){
    $("#jn").slideToggle();
    return false;
  });
  
  //check all checkboxes
  $("a.select_all").live('click', function(){
    $('table').find(':checkbox').attr('checked', true);
    return false;
  });

  //uncheck all checkboxes
  $("a.unselect_all").live('click', function(){
    $('table').find(':checkbox').attr('checked', false);
    return false;    
  });
      
  //Dynamic add field
  $('form a.add_child').click(function() {
     var association = $(this).attr('data-association');
     var template = $('#' + association + '_fields_template').html();
     var regexp = new RegExp('new_' + association, 'g');
     var new_id = new Date().getTime();
     $(this).parent().parent().find(".additional_fields").append(template.replace(regexp, new_id));
     return false;
   });
      
   //Dynamic remove field
   $('form a.remove_child').live('click', function() {
     var hidden_field = $(this).prev('input[type=hidden]')[0];
     if(hidden_field) {
       hidden_field.value = '1';
     }
     $(this).parent().parent('.additional_field').hide();
     return false;
   });
   
   //Dynamic add facility
   $('form a.add_facility').live('click', function() {
      $(this).parent().addClass("hide");
      $(".facilities").find(".facility").removeClass("hide").end().find("#facility_name").focus();
      
      return false;
    });
    
    // //Dynamic remove facility
    $('form a.remove_field').live('click', function() {
      $(this).parents(".facility").addClass("hide");
      $(this).parents(".facilities").find(":input:hidden").val("");
      $("#facility_toggle").removeClass("hide");
      return false;
    });   
     
  //select buttons with ids that start with btn-
  $("li[id|=btn]").click(function(){
    var el = $(this);
    if ( !el.hasClass("active") ) {
      el.addClass("active");
      el.siblings().removeClass("active");
      $("aside."+el.attr("data-panel")).animate({right:'10px'},{queue:false,duration:650});
      $("aside:not(aside."+el.attr("data-panel")+")").animate({right:'300px'},{queue:false,duration:750});
    }
    return false
  });
  
  if ( $("form #contact_facility_tokens").length ) {
    //Token for Contact Facility
    var token_path = $("form #contact_facility_tokens").data("path")
    $("form #contact_facility_tokens").tokenInput(token_path, {
        crossDomain: false,
        queryParam: "name",
        theme: "facebook",
        prePopulate: $("#contact_facility_tokens").data("pre"),
        minChars: 3,
        tokenLimit: 10,
        preventDuplicates: true,
        delay: 600
      });
  }

  if ( $("#note_content").length ) {
    $("#note_content").bind('keydown', 'alt+ctrl+s', function(){
      var el = $(this);
      el.parents("form").find("input[type='submit']").click();
    });
  }    
  
  $("#note_content").bind('keydown', 'alt+ctrl+s', function(){
      var el = $(this);
      el.parents("form").find("input[type='submit']").click();
    });

  if ( $("form #note_user_tokens").length ) {
    //Token for User Ids on Notes
    var user_token_path = $("form #note_user_tokens").data("path")
    $("form #note_user_tokens").tokenInput(user_token_path, {
        crossDomain: false,
        queryParam: "name",
        theme: "facebook",
        prePopulate: $("form #note_user_tokens").data("pre"),
        minChars: 3,
        tokenLimit: 10,
        preventDuplicates: true,
        delay: 600
      });
  }
  
  if ( $("form #candidate_relocation_tokens").length ) {
    //Token for US States on Candidates
    var relocation_token_path = $("form #candidate_relocation_tokens").data("path")
    $("form #candidate_relocation_tokens").tokenInput(relocation_token_path, {
        crossDomain: false,
        queryParam: "q",
        theme: "facebook",
        prePopulate: $("form #candidate_relocation_tokens").data("pre"),
        minChars: 5,
        tokenLimit: 10,
        preventDuplicates: true,
        delay: 600
      });
  }
  
  if ( $("form #note_contact_tokens").length ) {  
    //Token for Contact Ids on Notes
    var contact_token_path = $("form #note_contact_tokens").data("path")
    $("form #note_contact_tokens").tokenInput(contact_token_path, {
        crossDomain: false,
        queryParam: "name",
        theme: "facebook",
        prePopulate: $("#note_contact_tokens").data("pre"),
        minChars: 3,
        tokenLimit: 10,
        preventDuplicates: true,
        delay: 600
      });    
  }
  
  if ( $("form #note_job_tokens").length ) {  
    //Token for Job Ids on Notes
    var job_token_path = $("form #note_job_tokens").data("path")
    $("form #note_job_tokens").tokenInput(job_token_path, {
        crossDomain: false,
        queryParam: "name",
        theme: "facebook",
        prePopulate: $("#note_job_tokens").data("pre"),
        minChars: 3,
        tokenLimit: 10,
        preventDuplicates: true,
        delay: 600
      });  
  }
  
  //autocomplete Client Scoped facilites and contacts
  // var dual_cache = {};
  $('.panel .search input[type=search]:not(".general")').focus( function(){
    var el = $(this);
    var path = el.data("path");
    var client = el.data("client_id");
    var parent = el.parent();
    el.autocomplete({
      minLength: 3,
      delay: 600,
      source: function(request, response) {
        //         if ( request.term in dual_cache ) {
        //  response( dual_cache[ request.term ] );
        //  return;
        // }
        $.ajax({
          url: "/manage/clients/"+client+"/"+path,
          dataType: "json",
          data: {name: request.term},
          success: function( data ) {
    				// dual_cache[ request.term ] = data;
  					response( data );
          }
        });
      },
        select: function(event, ui){
          $.ajax({
            type: "GET",
            url: "/manage/clients/"+client+"/"+path+"/"+ui.item.id,
            dataType: "script",
            beforeSend: function() {
              $(".modal").remove();
              $('#flash').remove();
          		$("#content").after("<div class='modal' title='Loading'></div>");
              $("header#banner").after('<div id="flash"><div id="loading">Loading...</div></div>');
              centerFlashMessage();           
            },
            error: function(){
              $('#flash').remove();
              $("header#banner").after('<div id="flash"><div id="alert">Not Found. Please Try Again</div></div>');
              centerFlashMessage();           
            }
          });
        }
    });
  });
  
  if ( $("#locationSearchSelect").length ) {
    var regionSearch = $("#selectRegionSearch");
    var jobGeoSearch = $("#selectGeoSearch");
    var relocationSearch = $("#selectRelocateSearch");
    
    $("#locationSearchSelect").find("p:first span").click(function(){
      var el = $(this);
      el.attr("class", "button active").
        siblings("span").attr("class", "button");
      if ( el.attr("id") === regionSearch.attr("id") ) {
        $("#regionSearch").attr("class", "").
          siblings("div").attr("class", "hide");
        $("input:hidden#location_type").val("region");
      } else if ( el.attr("id") === jobGeoSearch.attr("id") ) {
        $("#jobGeoSearch").attr("class", "").
          siblings("div").attr("class", "hide");
        $("input:hidden#location_type").val("geo_search");
      } else if ( el.attr("id") === relocationSearch.attr("id") ) {
        $("#relocateSearch").attr("class", "").
          siblings("div").attr("class", "hide");
        $("input:hidden#location_type").val("relocation_search");
      }
      $("#locationSearchSelect").effect('highlight',{color: '#FDE00A'},'fast');
    });
  }
  
  //autocomplete Clients
  var client_cache = {};
  $('form #client_search_for_job').focus( function(){
    var el = $(this);
    var path = el.data("path");
    var parent = el.parent();
    el.autocomplete({
      minLength: 3,
      delay: 600,
      source: function(request, response) {
        if ( request.term in client_cache ) {
         response( client_cache[ request.term ] );
         return;
        }
        $.ajax({
          url: "/manage/autocomplete/"+path,
          dataType: "json",
          data: {name: request.term},
          success: function( data ) {
            client_cache[ request.term ] = data;
  					response( data );
          }
        });
      },
        select: function(event, ui){
          parent.find('input[id$="id"]:hidden').val(ui.item.id);
          parent.find('input[id$="name"]:hidden').val(ui.item.value);
          el.val(ui.item.value);
          //remove facilty if there
          parent.parent().find(".facilities").remove();
          //check for any client.facilities, if so, server will respond with input for facilitlies
          $.ajax({
            type: "GET",
            url: "/manage/clients/"+ui.item.id+"/check_facility",
            dataType: "script",
            beforeSend: function() {
              $('#flash').remove();
              $("header#banner").after('<div id="flash"><div id="loading">Checking for facilities...</div></div>');
              centerFlashMessage();           
            }
          });
        }
    });
  });
  
  //AutoComplete inserted Facility field on Job Form
  var facility_cache = {};
  $('form #facility_search').live('focus', function(){
    var el = $(this);
    var path = el.data("path");
    var this_client = el.data("client_id"); //needs updating for 1.6
    var parent = el.parent();
    el.autocomplete({
      minLength: 3,
      delay: 600,
      source: function(request, response) {
        if ( request.term in facility_cache ) {
         response( facility_cache[ request.term ] );
         return;
        }
        $.ajax({
          url: "/manage/clients/"+this_client+"/"+path,
          dataType: "json",
          data: {name: request.term},
          success: function( data ) {
            facility_cache[ request.term ] = data;
  					response( data );
          }
        });
      },
      select: function(event, ui){
        el.parents(".facilities").find('input[id$="tags"]:hidden').val(ui.item.id);
        el.parents(".facilities").find('input[id$="namings"]:hidden').val(ui.item.value);        
        el.val(ui.item.value);
      }
    });
  });
  
  //autocomplete General
  $('.search input[type=search].general, form input[type=text].general').live('focus', function(){
    var el = $(this);
    var geo = el.data("search");
    var path = el.data("path");
    var parent = el.parent();
    var goal = el.data("goal");
    el.autocomplete({
      minLength: 3,
      delay: 600,
      source: function(request, response) {
        $.ajax({
          url: "/manage/autocomplete/"+path,
          dataType: "json",
          data: {name: request.term},
          success: function( data ) {
  					response( data );
          }
        });
      },
      select: function(event, ui){
        if ( goal === "zip") { // set zip, city, and state from zip code autocomplete
          var top_parent = el.parents(".additional_field")
          el.val(ui.item.value);
          top_parent.find('input[id$="city"]').val(ui.item.city);
          top_parent.find('input[id$="state"]').val(ui.item.region);
        } else if ( goal === "job_location") {
          $('input[id$="geo_loc"]:hidden').val(ui.item.loc); //basic autocomplete and insert id to hidden field
          el.val(ui.item.value);
        } else {
          $('input[id$="'+goal+'"]:hidden').val(ui.item.id); //basic autocomplete and insert id to hidden field
          el.val(ui.item.value);
        }
      }
    });
  });
  
  //separate search types with category
  $.widget("custom.catcomplete", $.ui.autocomplete, {
		_renderMenu: function( ul, items ) {
			var self = this,
			currentCategory = "";
			$.each( items, function( index, item ) {
				if ( item.cat != currentCategory ) {
					ul.append( "<li class='ui-autocomplete-category'>" + item.cat + "</li>" );
					currentCategory = item.cat;
				}
				self._renderItem( ul, item );
			});
		}
	});
	
	$('.megaSearch #quickSearch').focus( function(){
  	var auto_cache = {};
	  var el = $(this);
    var path = el.data("path");
    var parent = el.parent();
  	el.catcomplete({
  		minLength: 4,
  		delay: 650,
  		source: function(request, response) {
  		  if ( request.term in auto_cache ) {
  				response( auto_cache[ request.term ] );
  				return;
  			}
        $.ajax({
          url: path,
          dataType: "json",
          data: {name: request.term},
          success: function( data ) {
  					auto_cache[ request.term ] = data;
  					response( data );
          }
        });
  		},
      select: function(event, ui){
        if ( (ui.item.cat === "Facilities") ) {
          $(".modal").remove();
          $('#flash').remove();
          $("#content").after("<div class='modal' title='Loading'></div>");
          $("header#banner").after('<div id="flash"><div id="loading">Loading...</div></div>');
          centerFlashMessage();
          $.get(ui.item.web, function(){
            $("#quickSearch").val("");
          }); 
        } else {
         location.href = ui.item.web;
        }
      }
  	});
	});
  
  //datePickers
  $(".openedDate").datepicker({defaultDate: 0, dateFormat: "MM dd, yy"});
  $(".interviewDate").datepicker({defaultDate: '+1m', dateFormat: "MM dd, yy"});
  $(".startDate").datepicker({defaultDate: '+2m', dateFormat: "MM dd, yy"});
  $(".surveyDate").datepicker({defaultDate: '-1m', dateFormat: "MM dd, yy"});
  
  $(".historyStartedDate").datepicker({defaultDate: '-1y', dateFormat: "MM dd, yy"});
  $(".historyEndedDate").datepicker({defaultDate: 0, dateFormat: "MM dd, yy"});  
  
  if ( $("#job_pending_offers").length ) {
    if ( $("#job_pending_offers:checked").length ) {
      $("#job_offers_sent_to").parents(".fields.long").removeClass("hide");
    } else {
      $("#job_offers_sent_to").parents(".fields.long").addClass("hide");
    }
    $("#job_pending_offers").click(function(){
      var el = $(this);
      if ( el.is(":checked") ) {
        $("#job_offers_sent_to").parents(".fields.long").removeClass("hide").effect('highlight',{color: '#FDE00A'},500);
      } else {
        $("#job_offers_sent_to").parents(".fields.long").addClass("hide");
        $("#job_offers_sent_to").val("");
      }
    });
  }
  
  //Add errors for dates
  if ( $("#error_explanation").length ) {
    if ( $("#error_explanation li:contains(Interview by)").length ) {
      $("#job-info").addClass("containsErrors").append('<em title="This section contains errors">Edit this Section to fix errors</em>');
      $("input[id$='interview_by']").parent().append('<span class="error_message">is not valid</span>');  
    }
    if ( $("#error_explanation li:contains(Starts on)").length ) {
      $("#job-info").addClass("containsErrors").append('<em title="This section contains errors">Edit this Section to fix errors</em>');
      $("input[id$='starts_on']").parent().append('<span class="error_message">is not valid</span>');  
    }
    if ( $("#error_explanation li:contains(Opened on)").length ) {
      $("#job-info").addClass("containsErrors").append('<em title="This section contains errors">Edit this Section to fix errors</em>');
      $("input[id$='opened_on']").parent().append('<span class="error_message">is not valid</span>');  
    }
    if ( $("#error_explanation li:contains(Started on)").length ) {
      $("#history-info").addClass("containsErrors").append('<em title="This section contains errors">Edit this Section to fix errors</em>');
      $("input[id$='started_on']").parent().append('<span class="error_message">is not valid</span>');  
    }
    if ( $("#error_explanation li:contains(provide an email)").length ) {
      $("#email-info").addClass("containsErrors").append('<em title="This section contains errors">You must add an email</em>');
    }
  }
  
  if ( $("a.edit_multiple").length ) {
    $("a.edit_multiple").click(function(e){
      e.preventDefault();
      var el = $(this);
      var parent_form = el.parents("form");
      var new_path = $(this).attr("href");
      el.text("Loading Candidates. . .");
      //Undelagate :remote => true, will die all forms, but thats ok in this instance
      $('form').die('submit.rails'); 
      $('form').die('ajax:beforeSend.rails');
      $('form').die('ajax:complete.rails');
      parent_form.attr("action", new_path);
      parent_form.removeAttr("data-remote");
      parent_form.find("input:submit").removeAttr("data-disable-with");
      parent_form.submit();
    });
  }
  
  //toggle additional info
  if ( $(".additional").length ) {
    $(".close").click(function() {
      $(".additional").slideToggle();
      $(".more").text("View More Info");
      return false;
    });

    $(".more").click(function() {
      var el = $(this);
      if ( $(".additional").is(":hidden") ) {
        $(".additional").slideToggle();
        el.text("Hide Extra Info");      
      } else {
        $(".additional").slideToggle();
        el.text("View More Info");
      }
      return false;
    });
  } else {
    $(".more").hide();
    $(".more, .close").click(function() {
      return false;      
    });
  }
  
  $(".load_more").live('ajax:success', function(){
    var el = $(this);
    var current_page_number = parseInt(el.data("page"));
    var next_page_number = current_page_number + 1;
    el.data("page", next_page_number);
    
  });
    
  $(".load_more").live('ajax:before', function(xhr, settings){
    var el = $(this);
    var path = el.data("path");
    var new_page_number = el.data("page");
    
    if ( el.data("per") === undefined ) {
      var per = 10;    
    } else {
      var per = el.data("per");    
    }
    
    if ( path.indexOf("?") != -1 ) {
      var new_path = path + "&page=" + new_page_number + "&per=" + per;
    } else {
      var new_path = path + "?page=" + new_page_number + "&per=" + per;
    }    
    el.attr("href", "");
    el.attr("href", new_path );
  });
  
  if ( $("table#dragSort").length ) {
    $("table#dragSort tbody").sortable({
      cursor: 'move',
      items: 'tr.drag',
      handle: 'span.handle',
      opacity: 0.9,
      scroll: true,
      axis: 'y',
      revert: true,
      update: function(){
        $(".modal").remove();
        $('#flash').remove();
        $("#content").after("<div class='modal' title='Loading'></div>");
        $("header#banner").after('<div id="flash"><div id="loading">Loading...</div></div>');
        centerFlashMessage();    
        
        $.ajax({
            type: 'post', 
            data: $("table#dragSort tbody").sortable("serialize"), 
            dataType: 'script', 
            url: $("table#dragSort").data("path"),
            success: function(){
              $('table#dragSort tr.table-row').effect('highlight',{color: '#FDE00A'},'fast');
              $('#flash').remove();
            }
        })
      }
    });
    $("td.order spane.handle").disableSelection();
  }
    
});

$(window).resize(function(){
  var new_height = ($(window).height() * 0.54);
  $("aside section.list").css({'height' : new_height + "px"});
});