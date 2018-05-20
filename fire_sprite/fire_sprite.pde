// Andrew Craigie
// fire_sprite.pde

// Creating a fire effect using two buffers, a Perlin noise array and transparent png images

PImage fireSourceImg;
AlphaSprite fireSource;

PImage foreSourceImg;
AlphaSprite foreSource;

NoiseArray noiseArr;
FireFilter fireF;

PImage iceSourceImg;
AlphaSprite iceSource;
PImage iceForeSourceImg;
AlphaSprite iceFore;

NoiseArray iceNoiseArr;
FireFilter iceF;

int filterWidth = 650;
int filterHeight = 300;

ArrayList<TransPixel> pixList;
ArrayList<TransPixel> icePixList;

int IcefilterWidth;
int IcefilterHeight;


float nIncrement = 0.0;

boolean decreasing = true;
int maxBright = 20;
int minBright = 5;

void setup() {
  size(800, 600);


  // FIRE
  // Load and create cropped and thresholded image as fire source
  fireSourceImg = loadImage("fire_fuel.png"); // 800 x 800
  fireSource = new AlphaSprite(fireSourceImg, 127);

  // Load and create cropped and thresholded image as foreground source
  foreSourceImg = loadImage("fire_fore.png");
  foreSource = new AlphaSprite(foreSourceImg, 127);

  int spriteWidth = fireSource.pixWidth;
  int spriteHeight = fireSource.pixHeight;

  filterWidth = (spriteWidth);
  filterHeight = (spriteHeight * 2);

  //NoiseArray (int array_width, int array_height, float bright, float increment)
  noiseArr = new NoiseArray(filterWidth, filterHeight, maxBright, 0.02);
  fireF = new FireFilter(filterWidth, filterHeight, noiseArr);

  fireF.flameMode = 2;
  fireF.startHue = 0.75 + 0.4;
  fireF.endHue = 0.4722 + 0.4;

  // Create ArrayList from fireSource AlphaSprite
  pixList = new ArrayList<TransPixel>();
  fireSource.sprite.loadPixels();

  for (int x = 0; x < fireSource.sprite.width; x++) {
    for (int y = 0; y < fireSource.sprite.height; y++) {
      int index = x + y * fireSource.sprite.width;
      color c = fireSource.sprite.pixels[index];
      TransPixel p = new TransPixel(new Point(x, y), c);
      pixList.add(p);
    }
  }

  // ICE
  iceSourceImg = loadImage("ice_fuel.png"); // 800 x 800
  iceSource = new AlphaSprite(iceSourceImg, 127);

  iceForeSourceImg = loadImage("ice_fore.png");
  iceFore = new AlphaSprite(iceForeSourceImg, 127);

  IcefilterWidth = (iceFore.sprite.width);
  IcefilterHeight = (iceFore.sprite.height * 2);

  iceNoiseArr = new NoiseArray(IcefilterWidth, IcefilterHeight, maxBright, 0.04);
  iceF = new FireFilter(IcefilterWidth, IcefilterHeight, iceNoiseArr);

  iceF.flameMode = 2;
  iceF.startHue = 0.75;
  iceF.endHue = 0.4722;

  iceF.blurDirection = -1;

  icePixList = new ArrayList<TransPixel>();
  iceSource.sprite.loadPixels();

  for (int x = 0; x < iceSource.sprite.width; x++) {
    for (int y = 0; y < iceSource.sprite.height; y++) {
      int index = x + y * iceSource.sprite.width;
      color c = iceSource.sprite.pixels[index];
      TransPixel p = new TransPixel(new Point(x, y), c);
      icePixList.add(p);
    }
  }
}

void updateFire() {

  // Experiment to see how fire quality can be changed through time

  // Pulse the fire effect by oscillating the noise_array brightness value up and down
  if (decreasing) {
    noiseArr.noise_brightness -= 0.2;
    iceNoiseArr.noise_brightness -= 0.2;
    if (noiseArr.noise_brightness < minBright) {
      decreasing = false;
    }
  } else {
    noiseArr.noise_brightness += 0.1;
    iceNoiseArr.noise_brightness += 0.1;
    if (noiseArr.noise_brightness > maxBright) {
      decreasing = true;
    }
  }

  // Draw an image to the FireFilter graphics
  //fireF.drawToGraphics(fireSource.sprite, 0, 100, 127);

  // ... or ...

  // Draw a ArrayList of TransPixels to the FireFilter graphics
  fireF.drawToGraphics(pixList, 0, filterHeight / 2, 1);
  fireF.blur();

  iceF.drawToGraphics(icePixList, 0, 10, 1);
  iceF.blur();
}



void draw () {
  background(0);

  updateFire();

  image(foreSource.sprite, ((width/2) - (fireF.w / 2)), (-60 + (fireF.h / 2)  ));
  image(fireF.get_image(), ((width/2) - (fireF.w / 2)), -60);

  image(iceFore.sprite, ((width/2) - (iceF.w / 2)), (280 + 10));
  image(iceF.get_image(), ((width/2) - (iceF.w / 2)), 280);
    
}
