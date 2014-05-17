library triangle;

import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';
part 'simpletriangle.dart';

void run() {
	int width = 320;
	int height = 240;
	BodyElement body = querySelector('body');
	CanvasElement canvas = new CanvasElement();

	canvas.setAttribute("width", width.toString());
	canvas.setAttribute("height", height.toString());

	body.append(canvas);

	CanvasRenderingContext context;
	assert(context == null);
	
	SimpleTriangle t;
	assert(t == null);
	try {
		t = new SimpleTriangle(canvas.getContext("webgl"));
	} on ContextNullError {
		print("no webgl found!");
	}
}

void main() {
	try {
		run();
	} on Exception catch (e) {
		print("unhandled exception");
		print(e);
	} catch (e, stackTrace) {
		print("unhandled error");
		print(e);
		print(stackTrace);
	}
}
