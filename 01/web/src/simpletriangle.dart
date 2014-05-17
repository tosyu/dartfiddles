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

  SimpleTriangle(CanvasRenderingContext this.context) {
    assert(context != null);
    if (context == null) {
      throw new ContextNullError("Context cannot be null!");
    }
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
          Float32List vdata = new Float32List.view(buffer);
          loadModel(vdata);
        });
      });
    });
  }

  void loadShaders(String vertexShaderSource, String fragmentShaderSource) {
    ShaderProgram p = context.createProgram();
    Shader sh = context.createVertexShader(gl.VERTEX_SHADER);
    context.shaderSource(sh);
    context.compileShader(sh);
    p.attachShader(sh);
    Shader sh = context.createVertexShader(gl.FRAGMENT_SHADER);
    context.shaderSource(sh);
    context.compileShader(sh);
    p.attachShader(sh);
    p.compileProgram();
  }

  void loadModel(Float32List vertexData) {
    print(vertexData);
  }
}
