// Generates the WealthWise AI launcher icon sources (package:image 4.x API).
//
//   dart run tool/generate_icon.dart
//   dart run flutter_launcher_icons
//
// Design: three rising round-topped bars (growth) and a gold coin (wealth)
// on brand teal.
import 'dart:io';

import 'package:image/image.dart' as img;

const _size = 1024;
final _teal = img.ColorRgba8(0x0F, 0x76, 0x6E, 255);
final _white = img.ColorRgba8(255, 255, 255, 255);
final _gold = img.ColorRgba8(0xF5, 0xB7, 0x00, 255);
final _clear = img.ColorRgba8(0, 0, 0, 0);

/// [scale] is the share of the canvas used by the artwork (keeps it inside
/// the adaptive-icon safe zone for the foreground layer).
img.Image _draw({required bool background, required double scale}) {
  final im = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(im, color: background ? _teal : _clear);

  final box = _size * scale;
  final x0 = (_size - box) / 2;
  final y0 = (_size - box) / 2;
  final barW = box * 0.2;
  final gap = box * 0.1;
  final r = (barW / 2).round();
  final bottom = (y0 + box * 0.92).round();
  const heights = [0.30, 0.48, 0.66];

  for (var i = 0; i < 3; i++) {
    final left = (x0 + box * 0.1 + i * (barW + gap)).round();
    final right = (left + barW).round();
    final top = (bottom - box * heights[i]).round();
    // Round top: a circle on top of a rectangle.
    img.fillCircle(im, x: left + r, y: top + r, radius: r, color: _white, antialias: true);
    img.fillRect(im, x1: left, y1: top + r, x2: right, y2: bottom, color: _white);
  }

  final coinX = (x0 + box * 0.1 + 2 * (barW + gap) + barW / 2).round();
  final coinY = (bottom - box * heights[2] - box * 0.15).round();
  img.fillCircle(im, x: coinX, y: coinY, radius: (box * 0.09).round(), color: _gold, antialias: true);
  return im;
}

void main() {
  final dir = Directory('assets/icon')..createSync(recursive: true);
  File('${dir.path}/icon.png')
      .writeAsBytesSync(img.encodePng(_draw(background: true, scale: 0.62)));
  File('${dir.path}/icon_foreground.png')
      .writeAsBytesSync(img.encodePng(_draw(background: false, scale: 0.5)));
  stdout.writeln('Wrote ${dir.path}/icon.png and icon_foreground.png');
}
