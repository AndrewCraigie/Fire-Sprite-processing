// Andrew Craigie
// alpha_sprite.pde

// Alpha Sprite
// 

class AlphaSprite {

  PImage source;
  PImage sprite;

  int threshold;

  int sourceWidth;
  int sourceHeight;

  int pixWidth = 0;
  int pixHeight = 0;

  int minX = Integer.MAX_VALUE;
  int maxX = -1;
  int minY = Integer.MAX_VALUE;
  int maxY = -1;

  int originXOffset = 0;
  int originYOffset = 0;


  AlphaSprite(PImage source_image, int thresh) {

    source = source_image;
    threshold = thresh;

    sourceWidth = source.width;
    sourceHeight = source.height;

    getBounds();
    makeSprite();
  }


  void getBounds() {

    source.loadPixels();

    for (int x = 0; x < sourceWidth; x++) {
      for (int y = 0; y < sourceHeight; y++) {

        int index = x + y * sourceWidth;
        color col = source.pixels[index];

        if (QColor.a(col) >= threshold) {
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }
      }
    }

    originXOffset = minX;
    originYOffset = minY;

    pixWidth = maxX - minX + 1;
    pixHeight = maxY - minY + 1;
  }

  void makeSprite() {

    sprite = createImage(pixWidth, pixHeight, RGB);

    source.loadPixels();
    sprite.loadPixels();

    // Grab the pixels from the source image 
    // within the bounds of the threshold pixels area
    for (int x = 0; x < pixWidth; x++) {
      for (int y = 0; y < pixHeight; y++) {

        int sourceIndex = (originXOffset + x) + (originYOffset + y) * sourceWidth;
        color sourceColor = source.pixels[sourceIndex];

        int spriteIndex = x + y * pixWidth;
        if (QColor.a(sourceColor) >= threshold) {
          sprite.pixels[spriteIndex] = sourceColor;
        } else {
          sprite.pixels[spriteIndex] = color(0, 0, 0, 1); // fill with fully transparent pixel
        }
      }
    }

    sprite.updatePixels();
  }
  
  
}
