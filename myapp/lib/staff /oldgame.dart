// add(Ground(defaultSize, defaultFieldNums, backgroundColor())
//   ..position = worldSize / 2);

// for (var i = 0; i < defaultFieldNums; i++) {
//   double angle = i * (2 * pi / defaultFieldNums) - (pi / defaultFieldNums);

//   Vector2 offset = Vector2(4 * defaultSize / 12, 0);
//   offset.rotate(angle);

//   add(LifePlace(defaultSize, defaultFieldNums, backgroundColor())
//     ..position = worldSize / 2
//     ..angle = angle);
// }

// add(Coin(defaultSize)..position = worldSize / 2);
// add(Heaven(defaultSize, defaultFieldNums)..position = worldSize / 2);

// for (var i = 0; i < defaultFieldNums; i++) {
//   double angle = i * (2 * pi / defaultFieldNums) - (pi / defaultFieldNums);

//   Vector2 pos = worldSize / 2;
//   Vector2 offset = Vector2(4 * defaultSize / 12, 0);
//   offset.rotate(angle);

//   add(Life(defaultSize)
//     ..position = pos + offset
//     ..angle = angle);
// }

// add(AngelBornPlace(defaultSize)
//   ..position = Vector2(defaultSize / 2, defaultSize / 10));


// SCROLL

//  @override
//   void onScroll(PointerScrollInfo info) {
//     double zoomStep = -info.scrollDelta.game.y / 100;
//     double zoom = camera.zoom + zoomStep;
//     if (zoomStep > 0) {
//       if (zoom < 3) {
//         Vector2 direction = info.eventPosition.game - cameraPosition;
//         camera.zoom = zoom;
//         cameraPosition.add((direction * zoomStep) / camera.zoom);
//       }
//     } else {
//       if (zoom >= 0.2) {
//         camera.zoom = zoom;
//         Vector2 direction = info.eventPosition.game - cameraPosition;
//         cameraPosition.add((direction * zoomStep) / camera.zoom);
//       } else {
//         cameraPosition.setFrom(worldSize / 2);
//       }
//     }

//     super.onScroll(info);
//   }
