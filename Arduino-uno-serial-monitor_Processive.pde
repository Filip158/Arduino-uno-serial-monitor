import processing.serial.*;
import java.awt.*;
import java.awt.image.*;

Serial myPort;

void setup() {
  // Wykrywanie i wybór portu COM
  println(Serial.list());
  String portName = "";
  for (String port : Serial.list()) {
    if (port.contains("usb") || port.contains("COM")) {
      portName = port;
      break;
    }
  }
  if (portName.isEmpty()) {
    println("Nie znaleziono odpowiedniego portu COM.");
    exit();
  } else {
    myPort = new Serial(this, portName, 2000000); // Zwiększamy prędkość portu szeregowego
    println("Połączono z: " + portName);
  }
  // Czekamy 7 sekund przed rozpoczęciem przesyłania obrazu
  delay(7000);
}

void draw() {
  try {
    Robot robot = new Robot();
    Rectangle captureSize = new Rectangle(Toolkit.getDefaultToolkit().getScreenSize()); // Przechwytujemy cały ekran
    BufferedImage bufferedImage = robot.createScreenCapture(captureSize);
    PImage img = new PImage(bufferedImage);
    img.resize(480, 320); // Dopasowanie obrazu do rozmiaru ekranu TFT
    img.loadPixels();
    
    myPort.write('S'); // Sygnał startowy
    myPort.write('T');
    println("Wysłano sygnał startowy 'ST'");
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int loc = x + y * img.width;
        color c = img.pixels[loc];
        int r = (int)red(c) & 0xFF; // Przesyłanie pełnych 8-bitowych kolorów
        int g = (int)green(c) & 0xFF; // Przesyłanie pełnych 8-bitowych kolorów
        int b = (int)blue(c) & 0xFF; // Przesyłanie pełnych 8-bitowych kolorów
        
        myPort.write(r); // Wysłanie czerwonego 8-bit
        myPort.write(g); // Wysłanie zielonego 8-bit
        myPort.write(b); // Wysłanie niebieskiego 8-bit
        
        println("Wysyłam piksel na: (" + x + ", " + y + ") - kolor 24-bitowy: R: " + r + " G: " + g + " B: " + b);
      }
      println("Wysłano pasek: " + y);
    }
    myPort.write('E'); // Sygnał końca
    println("Wysłano sygnał końca");
  } catch (AWTException e) {
    e.printStackTrace();
  }
  delay(100); // Małe opóźnienie
}
