import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../face_detection/face_detection_service.dart';

import '../../constants/model_file.dart';
import '../../utils/image_utils.dart';
import '../ai_model.dart';
/*
// ignore: must_be_immutable
class FaceMesh extends AiModel {
  FaceMesh({this.interpreter}) {
    loadModel();
  }

  final int inputSize = 192;

  @override
  Interpreter? interpreter;

  @override
  List<Object> get props => [];

  @override
  int get getAddress => interpreter!.address;

  @override
  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();

      interpreter ??= await Interpreter.fromAsset(ModelFile.faceMesh,
          options: interpreterOptions);

      final outputTensors = interpreter!.getOutputTensors();

      outputTensors.forEach((tensor) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  @override
  TensorImage getProcessedImage(TensorImage inputImage) {
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        //.add(NormalizeOp(0, 255))
        .add(NormalizeOp(127.5, 127.5))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  @override
  Map<String, dynamic>? predict(image_lib.Image image) {
    if (interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    final tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    final inputImage = getProcessedImage(tensorImage);

    TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(outputShapes[1]);

    final inputs = <Object>[inputImage.buffer];

    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputScores.buffer,
    };

    interpreter!.runForMultipleInputs(inputs, outputs);
    print("score:");
    print(outputScores.getDoubleValue(0));
    if (outputScores.getDoubleValue(0) < 0) {
      return null;
    }

    final landmarkPoints = outputLandmarks.getDoubleList().reshape([468, 3]);
    final landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        point[0] / inputSize * image.width,
        point[1] / inputSize * image.height,
      ));
    }

    return {'point': landmarkResults};
  }
}

Map<String, dynamic>? runFaceMesh(Map<String, dynamic> params) {
  final faceMesh =
      FaceMesh(interpreter: Interpreter.fromAddress(params['detectorAddress']));
  final image = ImageUtils.convertCameraImage(params['cameraImage']);
  final result = faceMesh.predict(image!);

  return result;
}
*/

// ignore: must_be_immutable
class FaceMesh extends AiModel {
  FaceMesh({this.interpreter}) {
    loadModel();
  }

  final int inputSize = 192;

  @override
  Interpreter? interpreter;

  @override
  List<Object> get props => [];

  @override
  int get getAddress => interpreter!.address;

  @override
  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();

      interpreter ??= await Interpreter.fromAsset(ModelFile.faceMesh,
          options: interpreterOptions);

      final outputTensors = interpreter!.getOutputTensors();

      outputTensors.forEach((tensor) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  @override
  TensorImage getProcessedImage(TensorImage inputImage) {
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        //.add(ResizeWithCropOrPadOp(inputSize, inputSize))
        //.add(NormalizeOp(0, 255))
        .add(NormalizeOp(127.5, 127.5))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  TensorImage getProcessedImage_2(TensorImage inputImage, dynamic result) {
    //print(result['bbox'].left);
    //print('firas');
    final left = result['bbox'].left.round();
    final top = result['bbox'].top.round();
    final right = result['bbox'].right.round();
    final bottom = result['bbox'].bottom.round();
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(bottom - top, right-left , left, top))
        //.add(ResizeWithCropOrPadOp(500,500, 50, 50))
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        //.add(ResizeWithCropOrPadOp(inputSize, inputSize, 0,0))
    //.add(NormalizeOp(0, 255))
        .add(NormalizeOp(127.5, 127.5))

        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  @override
  Map<String, dynamic>? predict(image_lib.Image image) {
    if (interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    final tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    final inputImage = getProcessedImage(tensorImage);

    TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(outputShapes[1]);

    final inputs = <Object>[inputImage.buffer];

    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputScores.buffer,
    };

    interpreter!.runForMultipleInputs(inputs, outputs);
    print("score mesh:");
    print(outputScores.getDoubleValue(0));
    if (outputScores.getDoubleValue(0) < 0) {
      return null;
    }

    final landmarkPoints = outputLandmarks.getDoubleList().reshape([468, 3]);
    final landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        point[0] / inputSize * image.width,
        point[1] / inputSize * image.height,
      ));
    }

    return {'point': landmarkResults};
  }

  Map<String, dynamic>? predict_2(image_lib.Image image, dynamic result) {
    if (interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    final left = result['bbox'].left.round();
    final top = result['bbox'].top.round();
    final right = result['bbox'].right.round();
    final bottom = result['bbox'].bottom.round();

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    final tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    final inputImage = getProcessedImage_2(tensorImage, result);
    //final inputImage = getProcessedImage(tensorImage);


    TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(outputShapes[1]);

    final inputs = <Object>[inputImage.buffer];

    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputScores.buffer,
    };

    interpreter!.runForMultipleInputs(inputs, outputs);
    final meshScore = outputScores.getDoubleValue(0);
    print("mesh score: $meshScore");
    if (meshScore < 0) {
      return null;
    }

    final landmarkPoints = outputLandmarks.getDoubleList().reshape([468, 3]);
    final landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        //point[0] / inputSize * image.width,
        //point[1] / inputSize * image.height,
        point[0] / inputSize * (right-left) + left,
        point[1] / inputSize *  (bottom - top) + top,
      ));
    }

    return {'point': landmarkResults};
  }


}

Map<String, dynamic>? runFaceMesh(Map<String, dynamic> params) {
  final faceDetection = FaceDetection(interpreter: Interpreter.fromAddress(params['faceDetection']));
  final image = ImageUtils.convertCameraImage(params['cameraImage'])!;
  final result = faceDetection.predict(image);


  final faceMesh =
      FaceMesh(interpreter: Interpreter.fromAddress(params['detectorAddress']));
  if (result == null){
    final result_2 = faceMesh.predict(image);
    return result_2;
  }else{
    final resultScore = result['score'];
    print("detect face square : $resultScore ");
    //print(result["score"]);
    bool FaceDetect_Then_FaceMesh = true;
    final result_mesh;
    if(FaceDetect_Then_FaceMesh) {
      result_mesh = faceMesh.predict_2(image, result);
    }else {
      result_mesh = faceMesh.predict(image);
    }
    return result_mesh;
  }

  //final result_2 = faceMesh.predict(image!);

  //return result_2;




}
