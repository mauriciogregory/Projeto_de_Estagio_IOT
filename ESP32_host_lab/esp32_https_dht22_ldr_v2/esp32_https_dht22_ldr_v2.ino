#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ArduinoHttpClient.h>
#include <WiFiClientSecure.h>
#include <DHT.h>
#include <ESP32Time.h>

ESP32Time rtc;

const int PinLDR = 32;
const int PinDHT11 = 33;

#define DHTTYPE DHT11
DHT dht(PinDHT11, DHTTYPE);

String tokenG;

const char* ssid = "Nome da Rede";
const char* pass = "Senha";

const char* rootCACertificate = R"string_literal(
-----BEGIN CERTIFICATE-----
MIIDbzCCAlegAwIBAgIELlIwtjANBgkqhkiG9w0BAQsFADBoMQ4wDAYDVQQGEwV0
ZXN0ZTEOMAwGA1UECBMFdGVzdGUxDjAMBgNVBAcTBXRlc3RlMQ4wDAYDVQQKEwV0
ZXN0ZTEOMAwGA1UECxMFdGVzdGUxFjAUBgNVBAMTDTE5Mi4xNjguMS4xMDAwHhcN
MjQwNzExMTYyMjA5WhcNMjQxMDA5MTYyMjA5WjBoMQ4wDAYDVQQGEwV0ZXN0ZTEO
MAwGA1UECBMFdGVzdGUxDjAMBgNVBAcTBXRlc3RlMQ4wDAYDVQQKEwV0ZXN0ZTEO
MAwGA1UECxMFdGVzdGUxFjAUBgNVBAMTDTE5Mi4xNjguMS4xMDAwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCOO9G6Bfn4bi0R1yEHbUTJyb2cgbZwpxYt
e2rp48+6B75R6hl+tfIEvSlmXLbhoynL2xIhHT+HtGyNuuYlVVsZlK0nCq9z3bv0
BUATKamb74BhQooJ11E4ycnpHnSJpJ1kdV51y32IEOESYZlTi+iBf4qnROP7pARd
TmmaXdcTJK1T4vNDQqnFBlN89/9nGZJB7vBo2yd8HW2dYmyIP1BaerxWeRe2rBWm
l5kKEDwc6/xhQ8vuD3hkNLSTnluzB5l8w4zLq5j09/Vq8RQC5YCrgvNNPLz1+ebI
KTRZQAElaHX7t9LTjSE6ryj5vBI1VBLlDmdnoqJQeaGuJ7V2P7QtAgMBAAGjITAf
MB0GA1UdDgQWBBRye0EVFy2c/avz4t2/7/9Nvb2RFTANBgkqhkiG9w0BAQsFAAOC
AQEAVcEjskP/ZXyj+KWujhTmNi5RPEClSCey+LydKvVEkXJZljoZ60alMaUKXhQd
XX2e1wQZmtXuo5lHZReqwH3rG/ElxU+L2/jEPM61pW+JwJwzi5kKtLZ3ZpzNpSWD
L2rHLnOvggX+CquwihikXrRE+8SpdIw0BLQdoaqunHejoRz96UNYIjP9a4hD54UV
VWWMjxezAuwKb/BBMEsqXaFyBBBEWFwToh0hSMuEshXneh5RNPa7d104C+4B5FnH
KRT1SQOZH4Od9aFL1VHpv6ahD/ymvmYSIPwsnHqQMW6uSkV15Vo++eqjyLwEr+QN
pqakl7Qsqiuoxzn57MpSYYniDg==
-----END CERTIFICATE-----
)string_literal";


int cadastro() {

  // login na API
  WiFiClientSecure* client = new WiFiClientSecure;
  client->setCACert(rootCACertificate);
  HTTPClient https;
  int code;
  Serial.print("[HTTPS] Cadastro...\n");
  if (https.begin(*client, "https://192.168.1.100:8443/api/cadastro")) {  // HTTPS
    https.addHeader("Content-Type", "application/json");

    StaticJsonBuffer<200> json;
    JsonObject& object = json.createObject();
    object["email"] = "teste@email.com";
    object["pass"] = "Teste123%&";
    object["question"] = "Security";
    object["usertype"] = "IOT";
    char json_char[200];

    object.prettyPrintTo(json_char, sizeof(json));
    Serial.println(json_char);
    code = https.POST(json_char);

    // se response -1 erro na conexão
    if (code > 0) {
      Serial.printf("[HTTPS] POST... code: %d\n", code);
      if (code == HTTP_CODE_OK || code == HTTP_CODE_MOVED_PERMANENTLY) {
        String payload = https.getString();
        Serial.println(payload);
      }
    } else {
      Serial.printf("[HTTPS] POST... erro: %s\n", https.errorToString(code).c_str());
    }
    https.end();
  } else {
    Serial.printf("[HTTPS] Erro na conexão\n");
  }
  return code;
  delete client;
  delay(100);
}

int login() {

  // login na API
  WiFiClientSecure* client = new WiFiClientSecure;
  client->setCACert(rootCACertificate);
  HTTPClient https;
  int code;
  Serial.print("[HTTPS] Login...\n");
  if (https.begin(*client, "https://192.168.1.100:8443/api/login")) {  // HTTPS
    https.addHeader("Content-Type", "application/json");

    StaticJsonBuffer<150> json;
    JsonObject& object = json.createObject();
    object["email"] = "teste@email.com";
    object["pass"] = "@Teste123%";
    char json_char[150];

    object.prettyPrintTo(json_char, sizeof(json));
    Serial.println(json_char);
    code = https.POST(json_char);

    // se response -1 erro na conexão
    if (code > 0) {
      Serial.printf("[HTTPS] GET... code: %d\n", code);
      if (code == HTTP_CODE_OK || code == HTTP_CODE_MOVED_PERMANENTLY) {
        String payload = https.getString();
        Serial.println(payload);
        const size_t capacidade = JSON_ARRAY_SIZE(300);
        StaticJsonBuffer<capacidade> JsonBuffer;
        JsonObject& parte = JsonBuffer.parse(payload);
        String token = parte["token"];
        Serial.println(token);
        tokenG = token;
      }
    } else {
      Serial.printf("[HTTPS] POST... erro: %s\n", https.errorToString(code).c_str());
    }
    https.end();
  } else {
    Serial.printf("[HTTPS] Erro na conexão\n");
  }
  return code;
  delete client;
  delay(100);
}

void ldr_Post(int valorLDR, String data) {
  WiFiClientSecure* client = new WiFiClientSecure;

  if (WiFi.isConnected()) {
    HTTPClient https;
    if (client) {
      int code;
      client->setCACert(rootCACertificate);
      Serial.print("[HTTPS] post LDR...\n");
      if (https.begin(*client, "https://192.168.1.100:8443/ldr")) {  // HTTPS
        https.addHeader("Content-Type", "application/json");
        https.addHeader("Accept", "application/json");
        https.addHeader("Authorization", "Bearer " + tokenG);

        StaticJsonBuffer<700> json;
        JsonObject& object = json.createObject();
        object["value"] = valorLDR;
        object["time"] = data;
        char json_char[700];

        object.prettyPrintTo(json_char, sizeof(json));
        Serial.println(json_char);
        code = https.POST(json_char);
      } else {
        Serial.printf("[HTTPS] POST...  erro: %s\n", https.errorToString(code).c_str());
      }
      https.end();
    } else {
      Serial.printf("[HTTPS] Erro na conexão\n");
    }
    delete client;
  } else {
    WiFi.setAutoConnect(true);
  }
  delay(100);
}


void DHT22_Post(float temperatura, float umidade, String data) {
  WiFiClientSecure* client = new WiFiClientSecure;

  if (WiFi.isConnected()) {
    HTTPClient https;
    if (client) {
      int code;
      client->setCACert(rootCACertificate);
      Serial.print("[HTTPS] post DHT22...\n");
      if (https.begin(*client, "https://192.168.1.100:8443/dht22")) {  
        https.addHeader("Content-Type", "application/json");
        https.addHeader("Accept", "application/json");
        https.addHeader("Authorization", "Bearer " + tokenG);

        StaticJsonBuffer<150> json;
        JsonObject& object = json.createObject();
        object["humidityValue"] = umidade;
        object["temperatureValue"] = temperatura;
        object["time"] = data;
        char json_char[150];

        object.prettyPrintTo(json_char, sizeof(json));
        Serial.println(json_char);
        code = https.POST(json_char);
      } else {
        Serial.printf("[HTTPS] POST...  erro: %s\n", https.errorToString(code).c_str());
      }
      https.end();
    } else {
      Serial.printf("[HTTPS] Erro na conexão\n");
    }
    delete client;
  } else {
    WiFi.setAutoConnect(true);
  }
  delay(100);
}

void setup() {

  Serial.begin(115200);
  // Serial.setDebugOutput(true);
  Serial.println();
  
  pinMode(PinLDR, INPUT);

  dht.begin();

  // setar data manualmente, 
  // ou usar um Módulo RTC para garantir que a data esteja setada sempre que o ESP for reinicializado
  rtc.setTime(00, 00, 00, 11, 07, 2024);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    Serial.println("Conectando...");
  }

  Serial.println("Conectado ao WiFi!");
  Serial.println(WiFi.localIP());
  delay(100);

  cadastro();
  delay(3000);

  while (login() != 200) {
    login();
    delay(1000);
  }
}

void loop() {
  Serial.println();

  Serial.println(rtc.getTime("%A, %B %d %Y %H:%M:%S")); 
  Serial.println(rtc.getTime("%Y-%m-%d %H:%M:%S")); 
  String data = rtc.getTime("%Y-%m-%d %H:%M:%S");

  int valorLDR = analogRead(PinLDR);
  if (valorLDR != NAN) {
    ldr_Post(valorLDR, data);
  } else {
    Serial.println("LDR sensor error!");
    valorLDR = 0;
    ldr_Post(valorLDR, data);
  }

  float temperatura = dht.readTemperature();
  float umidade = dht.readHumidity();

  if (temperatura != NAN && umidade != NAN) {
    DHT22_Post(temperatura, umidade, data);
  } else {
    Serial.println("DHT22 sensor error!");
    temperatura = 0;
    umidade = 0;
    DHT22_Post(temperatura, umidade, data);
  }

  delay(5000);
}