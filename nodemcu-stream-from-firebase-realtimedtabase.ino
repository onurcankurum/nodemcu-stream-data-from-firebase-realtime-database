
#include "FirebaseESP8266.h"  // Arduino IDE uzerinden library sekmesinden "Firebase ESP8266" isimli kutuphane yuklenecek
#include <ESP8266WiFi.h> // ESP
#include <Servo.h> //servo motor için gerekli kütüphane

#define FIREBASE_HOST "*************************" //firebase hostumuzun linki
#define FIREBASE_AUTH "***************" //firebase token firebase den alınıyor
#define WIFI_SSID "************"// wifi SSID
#define WIFI_PASSWORD "*********************"//wifi şifresi






//firebase Objesi 
FirebaseData ledData;

Servo servo;
void setup()
{

  Serial.begin(115200);
//wifi bağlantısı
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
 // firebase bağlantısını başlatacağız
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  //servo motor bağlantısı
  servo.attach(4);
  //burada bağlantıda hata çıkarsa yazdırıyoruz çıkmazsa devam ediyoruz.
  //ayrıca burada stream edilecek datanın yolunu da belirtiyoruz benimki led/led
    Serial.println("Begin stream 1...");
  if (!Firebase.beginStream(ledData, "led/led" ))
  {
    Serial.println("FAILED");
    Serial.println("REASON: " + ledData.errorReason());
    Serial.println();
  }
  else
  {
    Serial.println("PASSED");
    Serial.println("------------------------------------");
    Serial.println();
  }

}


void loop() {
  //stream i başlatıyoruz başlamazsa veya zaman aşımına uğrarsa hata mesajı dönüyor 
 if (!Firebase.readStream(ledData))
  {
    Serial.println("Can't read stream data");
    Serial.println("REASON: " + ledData.errorReason());
    Serial.println();
  }
  //stream sırasında zaman aşımı oluşursa çalışacak kod
    if (ledData.streamTimeout())
  {
    Serial.println("Stream timeout, resume streaming...");
    Serial.println();
  }
         //stream süresince çalışacak bölüm
  
    if (ledData.streamAvailable())
  {
    Serial.println("------------------------------------");
    Serial.println("Stream Data Available...");
    Serial.println("STREAM PATH: " + ledData.streamPath());
    Serial.println("EVENT PATH: " + ledData.dataPath());
    Serial.println("DATA TYPE: " + ledData.dataType());
    Serial.println("EVENT TYPE: " + ledData.eventType());
    Serial.print("VALUE: ");
     if(ledData.boolData()==true){
     servo.write(170);
     delay(1000);
     servo.write(0);
     Firebase.setBool(ledData, "/led/led", false);
     }



  }




}
