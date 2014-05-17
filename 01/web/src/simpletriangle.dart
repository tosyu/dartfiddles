import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';
import 'package:vector_math/vector_math.dart';

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
  
  Buffer triangleVertexBuffer;
  Buffer triangleColorBuffer;

  Float32List vertexData;
  Float32List colorData;

  Program shaderProgram;

  int viewportWidth;
  int viewportHeight;

  Matrix4 mvMatrix;
  Matrix4 pMatrix;
  int aVertexPosition;
  int aVertexColor;
  UniformLocation umvMatrix;
  UniformLocation upMatrix;

  SimpleTriangle(CanvasRenderingContext this.context) {
    assert(context != null);
    if (context == null) {
      throw new ContextNullError("Context cannot be null!");
    }
    initSystem().then(draw);
  }

  Future initSystem() {
    Completer completer = new Completer();
    context.clearColor(0.0, 0.0, 0.0, 1.0);
    context.enable(DEPTH_TEST);

    viewportWidth = context.canvas.width;
    viewportHeight = context.canvas.height;

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
          Int32List header = new Int32List.view(buffer, 0, 2);
          int vertexVectorCount = (header[0] / Float32List.BYTES_PER_ELEMENT).toInt(); // divide byte size to get length
          int colorVectorCount = (header[1] / Float32List.BYTES_PER_ELEMENT).toInt();
          int vertexDataOffset = Int32List.BYTES_PER_ELEMENT * 2;
          int colorDataOffset = vertexDataOffset + header[0];
          vertexData = new Float32List.view(buffer, vertexDataOffset, vertexVectorCount);
          colorData = new Float32List.view(buffer, colorDataOffset, colorVectorCount);
          loadModel();
          completer.complete();
        });
      });
    });
    return completer.future;
  }

  void loadShaders(String vertexShaderSource, String fragmentShaderSource) {
    shaderProgram = context.createProgram();
    Shader sh = context.createShader(VERTEX_SHADER);
    context.shaderSource(sh, vertexShaderSource);
    context.compileShader(sh);
    context.attachShader(shaderProgram, sh);
    sh = context.createShader(FRAGMENT_SHADER);
    context.shaderSource(sh, fragmentShaderSource);
    context.compileShader(sh);
    context.attachShader(shaderProgram, sh);
    context.linkProgram(shaderProgram);
    context.useProgram(shaderProgram);
    
    aVertexPosition = context.getAttribLocation(shaderProgram, "aVertexPosition");
    context.enableVertexAttribArray(aVertexPosition);

    aVertexColor = context.getAttribLocation(shaderProgram, "aVertexColor");
    context.enableVertexAttribArray(aVertexColor);
    
    upMatrix = context.getUniformLocation(shaderProgram, "pMatrix");
    umvMatrix = context.getUniformLocation(shaderProgram, "mvMatrix");
  }

  void loadModel() {
    triangleVertexBuffer = context.createBuffer();
    context.bindBuffer(ARRAY_BUFFER, triangleVertexBuffer);
    context.bufferDataTyped(ARRAY_BUFFER, vertexData, STATIC_DRAW);

    triangleColorBuffer = context.createBuffer();
    context.bindBuffer(ARRAY_BUFFER, triangleColorBuffer);
    context.bufferDataTyped(ARRAY_BUFFER, colorData, STATIC_DRAW);
  }

  void draw(double timestamp) {
    context.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);

    pMatrix = makePerspectiveMatrix((45 * (PI / 180)), viewportWidth / viewportHeight, 0.1, 100.0);
    mvMatrix = new Matrix4.identity();

    mvMatrix.translate(-1.5, 0.0, -7.0);
    context.bindBuffer(ARRAY_BUFFER, triangleVertexBuffer); 
    context.vertexAttribPointer(aVertexPosition, 3, FLOAT, false, 0, 0);

    context.bindBuffer(ARRAY_BUFFER, triangleColorBuffer);
    context.vertexAttribPointer(aVertexColor, 4, FLOAT, false, 0, 0);

    Float32List tmp = new Float32List(16);
    pMatrix.copyIntoArray(tmp);
    context.uniformMatrix4fv(upMatrix, false, tmp);
    mvMatrix.copyIntoArray(tmp);
    context.uniformMatrix4fv(umvMatrix, false, tmp);
    
    context.drawArrays(TRIANGLES, 0, (vertexData.length / 3).toInt());

    window.requestAnimationFrame(draw);
  }
}
