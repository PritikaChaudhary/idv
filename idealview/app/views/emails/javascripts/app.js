/* <![CDATA[ */
(function($){
	
	"use strict";
	
    $(document).ready(function(){
         
    
    /* Superfish
    ================================================== */
    $(function(){ // run after page loads
        $('#navigation ul.menu')
        .find('li.current_page_item,li.current_page_parent,li.current_page_ancestor,li.current-cat,li.current-cat-parent,li.current-menu-item')
            .addClass('active')
            .end()
            .superfish({autoArrows    : true});
    });
    
    /* FitVid
    ================================================== */
    $(".lambda-video, .post, .entry-content, .lambda_widget_video, .entry-media, .thumb").fitVids();
    
    /* Tooltips
    ================================================== */
    $('.pformat, .lambda-sociallinks li a').tooltip();
    
    /* Close Alerts
    ================================================== */
    $('.alert button').click(function(){
        $(this).parent().slideUp();
    });
    
    /* Last Child & First Child
    ================================================== */    
    $('ul.archive li:last-child').addClass('last');
    $('.widget-container ul li:last-child').addClass('last');
    $('.faq .list:last-child').addClass('last');
    $('#mobile-menu .sub-menu li:last-child').addClass('last');
    $('#mobile-menu li:last-child').addClass('last');
    
    $('#navigation li:first-child a').addClass('first');
    $('#mobile-menu .sub-menu li:first-child').addClass('first');
  
    /* Youtube WMode
    ================================================== */
    $('iframe').each(function() {
        var url = $(this).attr("src");
        
        if (url!==undefined) {
        var youtube = url.search("youtube"),
            splitable = url.split("?");
                
            if(youtube > 0 && splitable[1]) {
                $(this).attr("src",url+"&wmode=transparent");
            }
            
            if(youtube > 0 && !splitable[1]) {
                $(this).attr("src",url+"?wmode=transparent");
            }
        
        }
        
    });
    
    /* Mobile Menu
    ================================================== */
    $(function(){ // run after page loads
        //Switch the "Open" and "Close" state per click then slide up/down (depending on open/close state)
        $(".mm-trigger").click(function(){
            $(this).toggleClass("active").next().slideToggle(500);
            return false; //Prevent the browser jump to the link anchor
        });
    });
        
    function mobilemenu(){
                
         if (($(window).width() > 979)) {
            $("#mobile-menu").hide(); 
         }
        
    }
            
    var mobiletimer;
	
    $(window).resize(function(){
      clearTimeout(mobiletimer);
      mobiletimer = setTimeout(mobilemenu, 100);
    });
    
    
    // valid XHTML method of target_blank
    $(function(){ // run after page loads
        $('a[rel*=external]').click( function() {
            window.open(this.href);
            return false;
        });
    });

    /* scroll to top
    ================================================== */    
    $(window).scroll(function() {
        if($(this).scrollTop() !== 0) {
            $('#toTop').fadeIn();    
        } else {
            $('#toTop').fadeOut();
        }
    });
     
    $('#toTop').click(function() {
        $('body,html').animate({scrollTop:0},1000);
    });    
    

});

})(jQuery);
 /* ]]> */