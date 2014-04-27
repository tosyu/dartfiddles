import 'dart:html'; 
import 'dart:io';

class ContextNullError extends Error {
  ContextNullError(msg) : super(msg);
}

class SimpleTriangle {
  CanvasRenderingContext context;

  SimpleTriangle(CanvasRenderingContext context) {
    assert(context != null);
    if (context == null) {
      throw new ContextNullError("Context cannot be null!");
    }
    this.context = context;
    assert(this.context == context);

    // load shaders
    File vertexShaderFile = new File("shaders/vertex.shader");
    File fragmentShaderFile = new File("shaders/fragment.shader");

    String vertexShaderSource = vertexShaderFile.readAsStringSync();
    String fragmentShaderSource = fragmentShaderFile.readAsStringSync();
  }
}
