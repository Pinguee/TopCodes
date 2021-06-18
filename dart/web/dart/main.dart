/*
 * Tern Tangible Programming Language
 * Copyright (c) 2016 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (version 2) as
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
library topcodes;

import 'package:js/js.dart';

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:js' as js;
import 'dart:convert';

part 'scanner.dart';
part 'topcode.dart';
part 'video.dart';

@JS('scanCanvas')
external set _scanCanvas(String Function(ImageElement) f);

String scanCanvas(ImageElement image) {
  CanvasElement canvas = document.getElementById("video-canvas");
  canvas.height = image.height;
  canvas.width = image.width;
  print(image.height);

  Scanner scanner = new Scanner();
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.drawImage(image, 0, 0);
  ImageData id = ctx.getImageData(0, 0, image.width, image.height);
  List<TopCode> codes = scanner.scan(id, ctx);

  // draw topcodes
  List<dynamic> blah = [];
  for (TopCode top in codes) {
    top.draw(ctx);
    blah.add(top.toJSON());
  }
  var json = { "topcodes" : blah };
  return jsonEncode(json);
}

void initVideoScanner(String canvasId) {
  new VideoScanner(canvasId);
}


void main() {
  js.context['topcodes_initVideoScanner'] = initVideoScanner;
  _scanCanvas = js.allowInterop(scanCanvas);

  FileUploadInputElement input = document.getElementById("fileInput");

  input.onInput.listen((event) {
    var file = input.files[0];
    var reader = new FileReader();
    reader.onLoad.listen((event) {
      var image = new ImageElement();
      image.onLoad.listen((event) {
        print(scanCanvas(image));
      });
      image.src = reader.result;
    });
    reader.readAsDataUrl(file);
  });
}
