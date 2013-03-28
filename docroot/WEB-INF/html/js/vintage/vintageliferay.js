$(document).ready(function() {
	initsliders();
});


function saveCanvas(oCanvas, strType) {
	var bRes = false;
	if (strType == "PNG")
		bRes = Canvas2Image.saveAsPNG(oCanvas);
	if (strType == "BMP")
		bRes = Canvas2Image.saveAsBMP(oCanvas);
	if (strType == "JPEG")
		bRes = Canvas2Image.saveAsJPEG(oCanvas);

	if (!bRes) {
		alert("Sorry, this browser is not capable of saving " + strType + " files!");
		return false;
	}
}


/*default events*/
function applyvintagefilter(title){
	var selected = $("#selectedvintagefilter option:selected");		
	var filter = "";
	var filteredimage = "";

	//Get selector filter
	if(selected.val() != 0){
		filter = selected.text();
	}
	
    $("img.lfr-preview-file-image-current").vintage({
    	preset: filter
    });
}

/*sliders configuration*/
function initsliders() {
	$( "#red, #green, #blue" ).slider({
		orientation: "horizontal",
		range: "min",
		max: 255,
		value: 127,
		slide: refreshSwatch,
		change: refreshSwatch
	});
	
	$( "#red" ).slider( "value", 255 );
	$( "#green" ).slider( "value", 140 );
	$( "#blue" ).slider( "value", 60 );
};

/*sliders events*/
function refreshSwatch() {
	var red = $( "#red" ).slider( "value" );
	var green = $( "#green" ).slider( "value" );
	var blue = $( "#blue" ).slider( "value" );
}