// Andrew Craigie
// FireFilter class

import java.awt.Color;

class FireFilter {

  PGraphics graphics;      // Draw 'fire' graphics to here
  PGraphics buffer2;

  PImage fireSourceImage;  // Source image to be re-drawn to graphics

  PImage image;

  NoiseArray noise_array;

  int w;
  int h;
  float hue;
  float hue_increment = 0.0;
  float sat;
  float light;

  int flameMode = 1;
  
  float startHue = 0.0;
  float endHue = 1.0;
  
  int blurDirection = 1;

  FireFilter(int image_width, int image_height) {

    w = image_width;
    h = image_height;

    graphics = createGraphics(w, h);
    buffer2 = createGraphics(w, h);
    image = createImage(w, h, RGB);

    initialize_buffers();
  }

  FireFilter(int image_width, int image_height, NoiseArray n_array) {

    w = image_width;
    h = image_height;

    graphics = createGraphics(w, h);
    buffer2 = createGraphics(w, h);

    image = createImage(w, h, RGB);

    initialize_buffers();
    noise_array = n_array;
  }


  void initialize_buffers() {

    graphics.beginDraw();
    graphics.noStroke();
    graphics.loadPixels();
    for (int i = 0; i < graphics.pixels.length; i++) {
      graphics.pixels[i] = color(0, 0, 0, 1);  // Set pixel alpha to zero to hide perlin noise at start
    }
    graphics.updatePixels();
    graphics.endDraw();

    buffer2.beginDraw();
    buffer2.noStroke();
    buffer2.loadPixels();
    for (int i = 0; i < buffer2.pixels.length; i++) {
      buffer2.pixels[i] = color(0, 0, 0, 1);  // Set pixel alpha to zero to hide perlin noise at start
    }
    buffer2.updatePixels();
    buffer2.endDraw();
  }

  void clear_graphics() {
    graphics.clear();
  }

  int r(color forR) {
    return (forR >> 16) & 0xFF;
  }
  int g(color forG) {
    return (forG >> 8) & 0xFF;
  }
  int b(color forB) {
    return (forB & 0xFF);
  }
  int a(color forA) {
    return (forA >> 24) & 0xFF;
  }

  void blur() {

    // Blur using the two buffer images
    buffer2.beginDraw();
    graphics.loadPixels();
    buffer2.loadPixels();

    image.loadPixels();


    for (int x = 1; x < w-1; x++) {
      for (int y = 1; y < h-1; y++) {

        int index = x + y * w;

        int index1 = (x + 1) + (y) * w;
        int index2 = (x -1) + (y) * w;
        int index3 = (x) + (y + 1) * w;
        int index4 = (x) + (y-1) * w;

        color c1 = graphics.pixels[index1];
        color c2 = graphics.pixels[index2];
        color c3 = graphics.pixels[index3];
        color c4 = graphics.pixels[index4];

        int draw_to_index = x + (y-blurDirection) * w; // Set blurring 'direction'

        int newR = int((r(c1) + r(c2) + r(c3) + r(c4))  * 0.25);
        int newG = int((g(c1) + g(c2) + g(c3) + g(c4))  * 0.25);
        int newB = int((b(c1) + b(c2) + b(c3) + b(c4))  * 0.25);
        int newA = int((a(c1) + a(c2) + a(c3) + a(c4))  * 0.25);

        if (noise_array != null) {
          newA = newA - int((noise_array.get_value_at(index) ));
        }

        color pixColor = color(newR, newG, newB, newA);

        if (flameMode == 2) {
          
          // TODO
          // Figure out a way of mapping alpha values to certain colour bands
          // Possibly a lookup table?

          // Calculate a hue based on the alpha value
          //hue = map(newA, 0, 255, startHue, endHue);
          hue = map((newA % 127), 127, 10, startHue, endHue);
          color hsbColor = Color.HSBtoRGB(hue, 1.0, 1.0);

          int hsbR = QColor.r(hsbColor);
          int hsbG = QColor.g(hsbColor);
          int hsbB = QColor.b(hsbColor);
          pixColor = color (hsbR, hsbG, hsbB, newA);
          
        }

        buffer2.pixels[draw_to_index] = pixColor;

        color fullTransparent = color(0, 0, 0, 1);

        // Clear left edge pixels
        if (x == 1) {
          int leftEdgeXIndex = 0 + y * w; 
          image.pixels[leftEdgeXIndex] = fullTransparent;
        }

        // Clear right edge pixels
        if (x == w-2) {
          int rightEdgeXIndex = (x + 1) + y * w; 
          image.pixels[rightEdgeXIndex] = fullTransparent;
        }

        // Clear top edge pixels
        if (y == 1) {
          int topEdgeYIndex = x + (y - 1) * w; 
          image.pixels[topEdgeYIndex] = fullTransparent;
        }

        image.pixels[index] = pixColor;
      }
    }

    // The alpha of pixels in bottom two rows must be set to zero
    // to stop flames being generated at bottom of image
    for (int i = buffer2.pixels.length - (w * 2); i < buffer2.pixels.length; i++) {
      buffer2.pixels[i] = color(0, 0, 0, 0);
      image.pixels[i] = color(0, 0, 0, 0);
    }

    image.updatePixels();
    buffer2.updatePixels();
    buffer2.endDraw();

    // Swap
    PGraphics temp = graphics;
    graphics = buffer2;
    buffer2 = temp;

    if (noise_array != null) {
      noise_array.scroll();
    }
  }

  void drawToGraphics(ArrayList<TransPixel> pixList, int xLoc, int yLoc, int threshold) {

    graphics.beginDraw();
    graphics.loadPixels();

    // Interate through ArrayList
    for (int i = 0; i < pixList.size(); i++) {

      TransPixel p = pixList.get(i);
      int pX = p.loc.x;
      int pY = p.loc.y;
      color c = p.c;

      // Only draw pixels above certain threshold
      if (QColor.a(c) > threshold) {

        int gX = pX + xLoc;
        int gY = pY + yLoc;
        int gIndex = gX + gY * graphics.width;

        graphics.pixels[gIndex] = c;
      }
    }

    graphics.updatePixels();
    graphics.endDraw();
  }

  void drawToGraphics(PImage img, int xLoc, int yLoc, int threshold) {

    graphics.beginDraw();
    graphics.loadPixels();

    img.loadPixels();

    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {

        int index = x + y * img.width;
        color c = img.pixels[index];

        int gX = x + xLoc;
        int gY = y + yLoc;
        int gIndex = gX + gY * graphics.width;

        // Need to check that gIndex is within bounds of the filter x, y, width, height
        if ((gX > graphics.width - 1) || (gX < 0) || (gY < 0) || (gY > graphics.height- 1)) {
          continue;
        } else {
          if (QColor.a(c) > threshold) {
            graphics.pixels[gIndex] = c;
          }
        }
      }
    }


    graphics.updatePixels();
    graphics.endDraw();
  }

  PImage get_image() {
    return image;
  }
}
