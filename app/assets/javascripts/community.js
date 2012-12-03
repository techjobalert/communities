// Select communities - convert to coffee script and extract to community.js.coffee
////////////////////////////////////////////////////////////////////////////////////
var commButtonUnchecked = "url(/assets/communities/##ICON##.png)";
var commButtonChecked = "url(/assets/communities/##ICON##_checked.png)";
var currUrl = window.location.toString();
//var ACTIVATE_SKINING = true;

//toggle individual community selection button image on click
$(function() {
	dropdown_init();
	
	$(".dropdown-selectbox button").button().click(function(event) {
		event.preventDefault();
		$(this).parent().toggle('blind', {}, 100);
	});
	
	$("#comm_subscribe").click(function(event) {
		$("#community_selector").hide();
		$(".dropdown-selectbox.multiselect").css("position","relative");
		$(".dropdown-selectbox.multiselect").show();
		$(".dropdown-checklist-container.hidden.dialog").dialog( "open" );
	});
	
	// open dropdown when textbox clicked
	$(".dropdown-textbox").click(function() {
		$(".dropdown-selectbox").toggle('blind', {}, 100);
		return false;
	});

	//activates dropdown from toolbar
	$(".dropdown-button").click(function() {
		$(".dropdown-selectbox.redir").css("top",26);
		$(".dropdown-selectbox.redir").css("left", ($(this).offset().left - $(".dropdown-selectbox").width() + $(this).width()));
		$(".dropdown-selectbox.redir").toggle('blind', {}, 100);
		return false;
	});
	
	
	$(".dropdown-selectbox.multiselect label").click(function() {
		set_icon_multiselect(this, !get_checkbox_status(this));
	});
	
	
	$(".dropdown-selectbox.redir label").click(function() {
		var subdomain = $(this).attr("subdomain");

		//disable click if already in subdomain
		if (currUrl.indexOf(subdomain) > 0) return;
		
		//build path
		var parts = currUrl.split('.');
		var url = "";
		if (parts.length > 1) {
			parts[0] = "http://" + subdomain;
			url = parts.join(".");
		} else {
			url = parts[0].replace("http://", "http://" + subdomain + ".");
		}
		
		//redirect
		window.location = url;
	});
	
	$(".dropdown-checklist-container.hidden.dialog").dialog({
		autoOpen: false,
		resizable: false,
		width: 350,
		minHeight: "auto",
		modal: true,
		buttons: {
		  "Submit": function() {
		    $("[id^=update_communities_form]").submit();
		  },
		  Cancel: function() {
		    $( this ).dialog( "close" );
		  }
		}
	});
});


// initialize dropdown implementation
function dropdown_init() {
	var dropdown = $(".dropdown-selectbox");
	var multiselect = $(".dropdown-selectbox.multiselect");
	multiselect.width(213);

	dropdown.hide();

	hide_checkboxes();

	var label = $(".dropdown-selectbox.multiselect label, .dropdown-selectbox.redir label");
	adjust_label(label);

	label.each(function() {
		set_icon_multiselect(this, get_checkbox_status(this));
	});


	
}

function hide_checkboxes() {
	$(".dropdown-selectbox input:checkbox, .dropdown-selectbox input:radio").hide();
}


function adjust_label(label) {
	label.text("");
}

function get_checkbox_status(label) {
	var chkName = $(label).attr("for");
	return ($("#" + chkName).attr("checked") !== undefined);
}



function set_icon_multiselect(label, imgToggle) {
	var iconUrl = imgToggle ? commButtonChecked : commButtonUnchecked;
	$(label).css("background-image", iconUrl.replace("##ICON##", $(label).attr("icon")));
}
