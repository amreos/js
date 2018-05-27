$(document).ready(function(){
  
  //center and fade flash messages
  function centerFlashMessageAndFade() {
    var flashMargin = ($(window).width() - $("#flash").width()) / 2; 
    $("#flash").css({'left' : flashMargin+"px"});
    $("#flash").delay(5000).fadeOut('slow', function() {$(this).remove();});
  }
  
  function centerFlashMessage() {
    var flashMargin = ($(window).width() - $("#flash").width()) / 2; 
    $("#flash").css({'left' : flashMargin+"px"});
  }
  
  centerFlashMessageAndFade();

  jQuery.fn.slideToggle = function(speed, easing, callback) {
   return this.animate({height: 'toggle'}, speed, easing, callback);  
  };
  
  $.fn.scroll_with_page = function(options){
    //extend defaults with new options
    var opts = $.extend({}, $.fn.scroll_with_page.defaults, options);
    var el = $(this);
    var current_offset = el.offset();  //Inspired by http://thinkminimal.net/
    var d = opts;

    $(window).scroll(function() {
      if ($(window).scrollTop() > current_offset.top) {
        el.stop().animate({
          marginTop: $(window).scrollTop() - current_offset.top + d.top_padding    
        }, 1200);
      } else {
        el.stop().animate({  
          marginTop: d.top_margin_after_scroll
        });
      };
    });
  };

  $.fn.scroll_with_page.defaults = {
    top_padding: 35,
    top_margin_after_scroll: 35
  };

  if ( $("nav.main ul li ul").length ) {
    $("nav.main ul").superfish();  
  }

  if ( $(".chzn, .chzn-deselect").length ) {
    $(".chzn").chosen();
    $(".chzn-deselect").chosen({allow_single_deselect:true});
  }
  
  if ( $(".faq_helper").length ) {
   $(".faq_helper").scroll_with_page({top_padding: 20, top_margin_after_scroll: 20});
  }
  
  $('#flash #notice, #flash #loading, #flash #alert').live('click', function(){
    $(this).fadeOut("fast");
    return false;
  });
  
  // Show and hide action links
  $('.c').live('mouseover mouseout', function(event) {
    if (event.type == 'mouseover') {
      $(this).find("div.links").show();
    } else {
      $(this).find("div.links").hide();
    }
  });
  
  if ( $("table tr div.grid-links").length ) {
    $('tr').live('mouseover mouseout', function(event) {
      if (event.type == 'mouseover') {
        $(this).find("div.grid-links").show();        
      } else {
        $(this).find("div.grid-links").hide();
      }
    });
  }

  $('a#back_to_bios').live('click', function(event) {
    $("section.single_bio").hide();
    $("section.bios").css("position", "relative");
    $("section.bios").animate({"left":"0","opacity":"show"},{queue:true,duration:300});
    // $('html, body').animate({scrollTop:260}, 'slow');    
    return false;
  });
    
  //hide/show adanced search form
  $('a.advanced_search').click(function() {
    $("#advanced_search").slideToggle();
    return false;
  });
  
  //ajax defaults
  $('a:not(".removeAttachment"), form:not("#new_question,.popup_form")').live('ajax:beforeSend', function(event, xhr, status) {
      // insert loading flash
      $(".modal").remove();
      $('#flash').remove();
      $("body").append("<div class='modal' title='Loading'></div>");
      $("body").append('<div id="flash"><div id="loading">Loading...</div></div>');
      centerFlashMessage();    
    });
  
  $("#advanced_search form").submit( function(){
    // insert loading flash
    $(".modal").remove();
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="loading">Searching...</div></div>');
    centerFlashMessage();
  }); 

  $('form#new_question, .form.popup_form').live('ajax:beforeSend', function(event, xhr, status) {
      // insert loading flash
      $('#flash').remove();
      $("body").prepend('<div id="flash"><div id="loading">Loading...</div></div>');
      centerFlashMessage();    
    });    
    
  $('a.generate').live('click', function(event, xhr, status) {
      // insert loading flash
      $(".modal").remove();
      $('#flash').remove();
      $("body").append("<div class='modal' title='Loading'></div>");
      $("body").append('<div id="flash"><div id="loading">Getting PDF...</div></div>');
      centerFlashMessageAndFade();    
    });    
    
  $("form#new_attachment input:submit").click(function(){
    // insert loading flash
    $(".modal").remove();
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="loading">Saving and Uploading to Cloud...</div></div>');
    centerFlashMessage();    
  });
  
  $('a').live('ajax:error', function(event, xhr, status) {
    // insert loading flash
    var error_code = xhr.status;
    var error_text;
    
    if (error_code === 404) {
      error_text = " your request was not found - it could have been deleted earlier or moved";
    } else {
      error_text = " there was an error";
    }
    
    $(".modal").remove();
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="alert">Sorry,'+error_text+'</div></div>');
    
    centerFlashMessageAndFade();    
  });
  
  $('.endlessItems a.delete').live('ajax:success', function(event, xhr, status) {
    var find_me = $(this).parent().parent().attr('data-id');

    $(".modal").remove();
    $('#flash').remove();
    $("header#banner").after('<div id="flash"><div id="notice">Deleted Successfully</div></div>');
    $('div[data-id='+find_me+']').effect("highlight", {color: "#FDE00A", mode: "hide"}, 800);
    centerFlashMessageAndFade();

  });

  $('.endlessItems a.finish, .panel.tasks a.finish').live('ajax:success', function(event, xhr, status) {
    var find_me = $(this).parent().parent().attr('data-id');

    $(".modal").remove();
    $('#flash').remove();
    $("body").append('<div id="flash"><div id="notice">Completed Task</div></div>');
    $('div[data-id='+find_me+']').effect("highlight", {color: "#FDE00A", mode: "hide"}, 800);
    centerFlashMessageAndFade();

  });
  
  $('.panel a.delete').live('ajax:success', function(event, xhr, status) {
    var find_me = $(this).parent().parent().attr('data-id');
    var count_holder = $(this).parents(".panel").find(".counter");
    var new_count = count_holder.text() - 1;
    var cache_plural = count_holder.siblings(".cache_type");
    
    if ( !$(this).parent().parent().hasClass("placed") ) {
      if ( new_count === 0 ) {  
        cache_plural.text(cache_plural.data("plural"));
      } else if ( new_count === 1 ) {
        cache_plural.text(cache_plural.data("singular"));
      }

      count_holder.text(new_count);
      $(".modal").remove();
      $('#flash').remove();
      $("body").prepend('<div id="flash"><div id="notice">Deleted Successfully</div></div>');
      $('div[data-id='+find_me+']').effect("highlight", {color: "#FDE00A", mode: "hide"}, 800);
      centerFlashMessageAndFade();
    }
    
  });
  
  $('.ui-accordion-content a.delete').live('ajax:success', function(event, xhr, status) {
    var find_me = $(this).parent().parent().attr('data-id');
    $(".modal").remove();
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="notice">Deleted Successfully</div></div>');
    $('div[data-id='+find_me+']').remove();
    if ( $("#accordionNotes div").length ) {
      $("#accordionNotes").accordion("destroy");
      $("#accordionNotes").accordion({
        collapsible: true,
        header: "div.note_title",
        autoHeight: false    
      });
      
    }   
    centerFlashMessageAndFade();    
  });
  
  $('tr a.delete').live('ajax:success', function(event, xhr, status) {
    var parent = $(this).parents("tr");
    $(".modal").remove();
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="notice">Deleted Successfully</div></div>');
    parent.remove();
    $("tr.table-row").removeClass("odd").removeClass("even");
    $('tr.table-row:odd').addClass('odd');
    $('tr.table-row:even').addClass('even');
    centerFlashMessageAndFade();    
  });
        
  $("#action-bar #new-shortcut").click(function(){
    if ($(this).hasClass("active") ) {
      $(this).removeClass("active");
      $("#action-bar ul").slideToggle(120);
    } else {
      $(this).addClass("active");
      $("#action-bar ul").slideToggle(130);
    }
  });
    
  $("#action-bar ul li").click(function(){
    var el = $(this);
    $('#flash').remove();
    $("body").prepend('<div id="flash"><div id="notice">Loading...</div></div>');
    var flashMargin = ($(window).width() - $("#flash").width()) / 2; 
    $("#flash").css({'left' : flashMargin+"px", 'top' : "10px"});
    location.href = el.attr("data-url");
  });
    
  function addErrorClassToAccordion() {
    var ui_parent = $("span.error_message").closest(".ui-accordion-content");
    var ui_parent_header = ui_parent.prev("h3.ui-accordion-header");
    ui_parent_header.addClass("containsErrors");
    $("<em title='This section contains errors'>Edit this Section to fix errors</em>").appendTo(ui_parent_header);
  }
  
  if ( $(".ui-accordion-content span.error_message").length ) {
  
    $("#accordionForm").accordion({
      collapsible: true,
      autoHeight: false,
      change: function(event, ui) { 
        addErrorClassToAccordion();
      },
      active: false    
    });
    addErrorClassToAccordion();
    
  } else if ( $("#accordionForm").length ) {
    $("#accordionForm").accordion({
      collapsible: true,
      autoHeight: false    
    });
  }
  
  if ( $("#accordionNotes div").length ) {
    $("#accordionNotes").accordion({
      collapsible: true,
      header: "div.note_title",
      autoHeight: false    
    });
  }  
    
  //accordion next / previous buttons
  if ( ('#accordionForm').length ) {
    $('#accordionForm a.next').each(function (index, elm) {
      if ( ($("#accordionForm div.ui-accordion-content").length - 1) === index ) {
        $(elm).hide();
      } else {
        $(elm).click(function() {
            $('#accordionForm').accordion('activate', index + 1);
            return false;
        }); 
      }
    });

    $('#accordionForm a.previous').each(function (index, elm) {
      if ( index === 0 ) {
        $(elm).hide();
      } else {
        $(elm).click(function() {
            $('#accordionForm').accordion('activate', index - 1);
            return false;
        });
      }
    });
  }
  
  if ( $("a.target_blank").length ) {
    $("a.target_blank").attr("target", "_blank");
  }
  
  if ( $("#johnVid").length ) {
    $('a[rel*=facebox]').facebox();
  }
  
  if ( $('body#contents').length ) {
    if ( $('.featured-points').length ) {
      $('.featured-points').orbit({
        animation: 'horizontal-slide',
        animationSpeed: 800,
        timer: true,
        resetTimerOnClick: false,
        advanceSpeed: 5250,
        pauseOnHover: true,
        startClockOnMouseOut: true,
        startClockOnMouseOutAfter: 800,
        directionalNav: false,
        captions: true,
        captionAnimation: 'slideOpen',
        captionAnimationSpeed: 800,
        bullets: true,        
        fluid: true
      });      
    }
  }

  if ( $('.public section.newsletters').length ) {
    $.getScript("/campaigns.js").
    fail(function(jqxhr, settings, exception) {
      $('.public section.newsletters .recent-campaigns').html("\
        <h4>We could not load any newsletters</h4> \
        <p>Sorry, please try again later.</p>");
    });
  }

  if ($("body.home").length ) {

    function setScrollerSizes() {
      var scrollerWidth = $(".explanations").width();
      $(".explanation").width(scrollerWidth - 10);
    }

    setScrollerSizes();    

    $(window).resize(function() { setScrollerSizes(); });
                    
    $('a.job_controls').click(function(){
      return false;
    });
    
    if ( !$('section.scrollable .items').children().length ) {
      $('a.job_controls').hide();
      $('section.scrollable .items').
        append('<div class="page"><div class="job"><h2>Looks Like Every Job is Placed</h2><p>Contact us again to find out the latest job placement oppurtunities.</p></div></div>');
    }
    
    if ( $('section.scrollable').length ) {
      $("section.scrollable").
        scrollable({circular: true, speed: 800}).
        autoscroll(5000);
      $(".job_controls.nexter").click(function(){
        $("section.scrollable").scrollable().next();
      });
      $(".job_controls.prever").click(function(){
        $("section.scrollable").scrollable().prev();
      });      
    }
    if ( $('.explanations').length ) {
      $(".explanations").
        scrollable({circular: true, speed: 800}).
        autoscroll(6000).navigator("ul#scroller-nav");
    }    
  }
  
  if ( $("html.manage").length ) {

    $(".states ul li a, .state, table-td current_state span").tipTip({ defaultPosition: "top", delay: 800 });
  }

});