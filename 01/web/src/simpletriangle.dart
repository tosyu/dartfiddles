part of triangle;

class TriangleException implements Exception {
  String _message;
  TriangleException([this._message]);
  String toString() => "ERROR: ${_message}";
}

class ContextNullError extends TriangleException {
  ContextNullError(msg) : super(msg);
}

class SimpleTriangle {
  final CanvasRenderingContext context;
  int aVertexPosition;
  UnitformLocation mvMatrix;
  UnitformLocation pMatrix;

  SimpleTriangle(CanvasRenderingContext this.context) {
    assert(context != null);
    if (context == null) {
      throw new ContextNullError("Context cannot be null!");
    }
    initSystem();
  }

  void initSystem() {
    context.clearColor(0.0, 0.0, 0.0, 1.0);
    context.enable(context.DEPTH_TEST);

    // load shaders
    HttpRequest.request("shaders/vertex.shader").then((HttpRequest response) {
      String vertexShaderSource = response.responseText;
      assert(vertexShaderSource != null);
      HttpRequest.request("shaders/fragment.shader").then((HttpRequest response) {
        String fragmentShaderSource = response.responseText;
        assert(fragmentShaderSource != null);
        loadShaders(vertexShaderSource, fragmentShaderSource);
        HttpRequest.request(
            "models/triangle.bin",
            method: "GET",
            responseType: "arraybuffer"
          ).then((HttpRequest response) {
          ByteBuffer buffer = response.response;
          Int32List header = new Int32List.view(buffer, 0, 1);
          int vertexLength = (header[0] / Float32List.BYTES_PER_ELEMENT).toInt(); // divide byte size to get length
          Float32List vertexData = new Float32List.view(buffer, Int32List.BYTES_PER_ELEMENT, 9);
          Float32List colorData = new Float32List.view(buffer, Int32List.BYTES_PER_ELEMENT + header[0], vertexLength);
          loadModel(vertexData, colorData);
        });
      });
    });
  }

  void loadShaders(String vertexShaderSource, String fragmentShaderSource) {
    Program p = context.createProgram();
    Shader sh = context.createShader(VERTEX_SHADER);
    context.shaderSource(sh, vertexShaderSource);
    context.compileShader(sh);
    context.attachShader(p, sh);
    sh = context.createShader(FRAGMENT_SHADER);
    context.shaderSource(sh, fragmentShaderSource);
    context.compileShader(sh);
    context.attachShader(p, sh);
    context.linkProgram(p);
    context.useProgram(p);
  }

  void loadModel(Float32List vertexData, Float32List colorData) {
    print(vertexData);
    print(colorData);
  }
}
