require('skeleton-css-webpack');
require('../assets/main.css');
var $ = require('jquery');

$(document).ready(function() {

	$('#submitButton').click(function() {	
		var formValues = {};
		$.each($('#wifiForm').serializeArray(), function(i, field) {
			formValues[field.name] = field.value;
		});
			
		if(formValues.ssid !== "" && formValues.password !== "") {
			$.get('/', {SSID: formValues.ssid, PASSWORD: formValues.password})
				.done(function(data) {
					$('#button').html(data);
				});
		}
	});

});



