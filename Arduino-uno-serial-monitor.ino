#include <Adafruit_GFX.h>
#include <MCUFRIEND_kbv.h>
#include <SPI.h>

MCUFRIEND_kbv tft;

#define LCD_CS A3 
#define LCD_CD A2
#define LCD_WR A1
#define LCD_RD A0
#define LCD_RESET A4 

void setup() {
  Serial.begin(2000000); // Zwiększamy prędkość portu szeregowego
  uint16_t identifier = tft.readID();
  tft.begin(identifier);
  tft.setRotation(1); // Ustawienie rotacji ekranu
  tft.fillScreen(tft.color565(0, 0, 0)); // Wypełnienie ekranu na czarno
  
  // Wyświetlanie napisu "Monitor_OS-USB" na środku ekranu przy uruchomieniu
  tft.setTextColor(tft.color565(255, 255, 255));
  tft.setTextSize(3);
  int16_t x1, y1;
  uint16_t w, h;
  tft.getTextBounds("Monitor_OS-USB", 0, 0, &x1, &y1, &w, &h);
  int x = (tft.width() - w) / 2;
  int y = (tft.height() - h) / 2;
  tft.setCursor(x, y);
  tft.print("Monitor_OS-USB");
  delay(3000); // Wyświetlanie napisu przez 3 sekundy
  tft.fillScreen(tft.color565(0, 0, 0)); // Czyszczenie ekranu
}

void loop() {
  if (Serial.available() > 0) {
    char start = Serial.read();
    if (start == 'S') {
      while (Serial.available() < 1) {} // Czekamy na drugi znak sygnału startowego
      if (Serial.read() == 'T') {
        Serial.println("Otrzymano sygnał startowy 'ST'");
        for (int y = 0; y < 320; y++) {
          for (int x = 0; x < 480; x++) {
            while (Serial.available() < 3) {} // Czekamy na pełne dane piksela (3 bajty na kolor)
            uint8_t red = Serial.read();
            uint8_t green = Serial.read();
            uint8_t blue = Serial.read();
            uint16_t color = tft.color565(red, green, blue); // Przekształcenie kolorów 8-bitowych na 16-bitowy kolor
            tft.drawPixel(x, y, color);
          }
        }
        Serial.println("Rysowanie zakończone");
      }
    }
  }
}
