#include "BluetoothAT09.h"

#include <Arduino.h>

#include "InputDevices/Menu/Menu.h"

BluetoothAT09::BluetoothAT09() {}

void BluetoothAT09::Initialize() {
    Serial1.begin(9600);
}

void BluetoothAT09::Update() {
    if (Serial1.available()) {
        String command = Serial1.readStringUntil('\n');
        command.trim();

        int spaceIndex = command.indexOf(' ');
        if (spaceIndex == -1) {
            Serial.println("Invalid command format");
            return;
        }

        String keyword = command.substring(0, spaceIndex);
        String valueStr = command.substring(spaceIndex + 1);
        valueStr.trim();
        int value = valueStr.toInt();

        keyword.toUpperCase();

        // TODO: filter for valid input

        if (keyword == "FACES") {
            Menu::SetFaceState(value);
        } else if (keyword == "BRIGHT") {
            Menu::SetBrightness(value);
        } else if (keyword == "ACCENTBRIGHT") {
            Menu::SetAccentBrightness(value);
        } else if (keyword == "MICROPHONE") {
            Menu::SetUseMicrophone(value);
        } else if (keyword == "MICLEVEL") {
            Menu::SetMicLevel(value);
        } else if (keyword == "BOOPSENSOR") {
            Menu::SetUseBoopSensor(value);
        } else if (keyword == "SPECTRUMMIRROR") {
            Menu::SetMirrorSpectrumAnalyzer(value);
        } else if (keyword == "FACESIZE") {
            Menu::SetFaceSize(value);
        } else if (keyword == "COLOR") {
            Menu::SetFaceColor(value);  // TODO: parse RGB if needed
        } else if (keyword == "HUEF") {
            Menu::SetHueF(value);
        } else if (keyword == "HUEB") {
            Menu::SetHueB(value);
        } else if (keyword == "EFFECTS") {
            Menu::SetEffectS(value);
        } else if (keyword == "FANSPEED") {
            Menu::SetFanSpeed(value);
            Serial1.println("Color: " + String(Menu::GetFaceColor()));
        } else {
            Serial.println("Unknown command: " + command);
        }
    }
}