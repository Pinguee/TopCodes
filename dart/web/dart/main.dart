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
  double scale = 1;
  print(scale);

  CanvasElement canvas = document.getElementById("image-canvas");

  if (image.width > 1500 && image.width > image.height) {
    scale = 1500/image.width;
  }
  if (image.height > 1500 && image.height > image.width) {
    scale = 1500/image.height;
  }

  print(scale);

  canvas.height = (image.height*scale).round();
  canvas.width = (image.width*scale).round();

  Scanner scanner = new Scanner();
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx.drawImage(image, 0, 0);
  ctx.save();
  {
    ctx.scale(scale, scale);
    ctx.drawImage(image, 0, 0);
  }
  ctx.restore();

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

void initVideoScannerM(String canvasId) {
  new VideoScannerMirror(canvasId);
}

void main() {
  js.context['topcodes_initVideoScanner'] = initVideoScanner;
  js.context['topcodes_initVideoScannerM'] = initVideoScannerM;
  _scanCanvas = js.allowInterop(scanCanvas);
}
