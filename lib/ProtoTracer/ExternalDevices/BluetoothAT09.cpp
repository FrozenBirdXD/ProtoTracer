#include "BluetoothAT09.h"

#include <Arduino.h>

#include "InputDevices/Menu/Menu.h"

BluetoothAT09::BluetoothAT09() {}

void BluetoothAT09::Initialize() { Serial1.begin(9600); }

void BluetoothAT09::Update() {
    Menu::SetFanSpeed(10);

    if (Serial1.available()) {
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

        if (keyword == "FACES") {
            Menu::SetFaceIndex(value);
        } else if (keyword == "BRIGHT") {
            Menu::SetBrightness(value);
        } else if (keyword == "ACCENTBRIGHT") {
            Menu::SetAccentBrightness(value);
        } else if (keyword == "MICROPHONE") {
            Menu::SetMicrophoneEnabled(value != 0);
        } else if (keyword == "MICLEVEL") {
            Menu::SetMicLevel(value);
        } else if (keyword == "BOOPSENSOR") {
            Menu::SetBoopSensorEnabled(value != 0);
        } else if (keyword == "SPECTRUMMIRROR") {
            Menu::SetSpectrumMirrorEnabled(value != 0);
        } else if (keyword == "FACESIZE") {
            Menu::SetFaceSize(value);
        } else if (keyword == "COLOR") {
            Menu::SetColor(value);  // TODO: parse RGB if needed
        } else if (keyword == "HUEF") {
            Menu::SetFrontHue(value);
        } else if (keyword == "HUEB") {
            Menu::SetBackHue(value);
        } else if (keyword == "EFFECTS") {
            Menu::SetEffect(value);
        } else if (keyword == "FANSPEED") {
            Menu::SetFanSpeed(value);
        } else {
            Serial.println("Unknown command: " + command);
        }
    }
}