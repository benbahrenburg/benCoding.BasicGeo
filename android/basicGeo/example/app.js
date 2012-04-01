// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

// TODO: write your module tests here
var basicgeo = require('bencoding.basicgeo');
Ti.API.info("module is => " + basicgeo);

label.text = basicgeo.example();

Ti.API.info("module exampleProp is => " + basicgeo.exampleProp);
basicgeo.exampleProp = "This is a test value";

if (Ti.Platform.name == "android") {
	var proxy = basicgeo.createExample({
		message: "Creating an example Proxy",
		backgroundColor: "red",
		width: 100,
		height: 100,
		top: 100,
		left: 150
	});

	proxy.printMessage("Hello world!");
	proxy.message = "Hi world!.  It's me again.";
	proxy.printMessage("Hello world!");
	win.add(proxy);
}

