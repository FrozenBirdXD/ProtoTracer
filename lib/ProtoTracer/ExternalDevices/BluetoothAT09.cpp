#include "BluetoothAT09.h"
#include "Examples/Templates/ProtogenProjectTemplate.h"
#include <Arduino.h>
#include <vector>
#include <sstream>  

void BluetoothAT09::GetProtoData() {
    
}

void BluetoothAT09::SendDataToPhone(const String& message) {
    Serial1.println(message);
}

// Helper function to split string by delimiter
std::vector<String> BluetoothAT09::splitString(const String& string, char delimiter) {
    std::vector<String> tokens;
    String token;
    for (char c : string) {
        if (c == delimiter) {
            tokens.push_back(token);
            token = "";
        } else {
            token += c;
        }
    }
    tokens.push_back(token); 
    return tokens;
}

void BluetoothAT09::HandleCommand(const String& command, const String& value) {
    if (!project) {
        return;
    }

    command.toUpperCase();

    uint8_t singleValue = value.toInt();
    bool singleValueValid = (singleValue >= 0 && value <= 9);

    if (command == "FACES") {
        if (singleValueValid) {
            project->SetFaceStateViaBLE(singleValue);
            SendDataToPhone("Set face state to " + String(singleValue));
        }

    } else if (command == "BRIGHT") {
        if (singleValueValid) {
            project->SetBrightnessViaBLE(singleValue);
            SendDataToPhone("Set brightness to " + String(singleValue));
        }
    } else if (command == "ACCENTBRIGHT") {
        if (singleValueValid) {
            project->SetAccentBrightnessViaBLE(singleValue);
            SendDataToPhone("Set accent brightness to " + String(singleValue));
        }
    } else if (command == "MICROPHONE") {
        if (singleValueValid && (singleValue == 0 || singleValue == 1)) {
            project->SetUseMicrophoneViaBLE(singleValue);
            SendDataToPhone("Set microphone usage to " + String(singleValue));
        }
    } else if (command == "MICLEVEL") {
        if (singleValueValid) {
            project->SetMicLevelViaBLE(singleValue);
            SendDataToPhone("Set microphone level to " + String(singleValue));
        }
    } else if (command == "BOOPSENSOR") {
        if (singleValueValid && (singleValue == 0 || singleValue == 1)) {
            project->SetUseBoopSensorViaBLE(singleValue);
            SendDataToPhone("Set boop sensor usage to " + String(singleValue));
        }
    } else if (command == "SPECTRUMMIRROR") {
        if (singleValueValid) {
            project->SetMirrorSpectrumAnalyzerViaBLE(singleValue);
            SendDataToPhone("Set spectrum analyzer mirror to " + String(singleValue));
        }
    } else if (command == "FACESIZE") {
        if (singleValueValid) {
            project->SetFaceSizeViaBLE(singleValue);
            SendDataToPhone("Set face size to " + String(singleValue));
        }
    } else if (command == "COLOR") {
        if (singleValueValid) {
            project->SetFaceColorByIndexViaBLE(singleValue);
            SendDataToPhone("Set face color index to " + String(singleValue));
        }
    } else if (command == "HUEF") {
        if (singleValueValid) {
            project->SetHueFViaBLE(singleValue);
            SendDataToPhone("Set hue F to " + String(singleValue));
        }
    } else if (command == "HUEB") {
        if (singleValueValid) {
            project->SetHueBViaBLE(singleValue);
            SendDataToPhone("Set hue B to " + String(singleValue));
        }
    } else if (command == "EFFECTS") {
        if (singleValueValid) {
            project->SetEffectsViaBLE(singleValue);
            SendDataToPhone("Set effects to " + String(singleValue));
        }
    } else if (command == "FANSPEED") {
        if (singleValueValid) {
            project->SetFanSpeedViaBLE(singleValue);
            SendDataToPhone("Set fan speed to " + String(singleValue));
        }
    } else if (command == "COLOR_RGB") {
        std::vector<String> rgbStrings = splitString(value, ',');
        if (rgbStrings.size() == 3) {
            uint8_t r = rgbStrings[0].toInt();
            uint8_t g = rgbStrings[1].toInt();
            uint8_t b = rgbStrings[2].toInt();
            if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255) {
                project->SetFaceColorRGBViaBLE(r, g, b);
                SendDataToPhone("Set face color RGB to (" + String(r) + ", " + String(g) + ", " + String(b) + ")");
            } 
        }
    } else {
        SendDataToPhone("Unknown command: " + command + " with value: " + value);
    }
}

BluetoothAT09::BluetoothAT09() {}

// Initialize the Bluetooth module and project instance
void BluetoothAT09::Initialize(ProtogenProject* proj) {
    project = proj;
    Serial1.begin(9600);
}

void BluetoothAT09::Update() {
    if (Serial1.available()) {
        String command = Serial1.readStringUntil('\n');
        command.trim();

        int spaceIndex = command.indexOf(' ');
        if (spaceIndex == -1) {
            SendDataToPhone("Invalid command format. Expected: <COMMAND> <VALUE>");
            return;
        }

        String keyword = command.substring(0, spaceIndex);
        String value = command.substring(spaceIndex + 1);
        value.trim();

        HandleCommand(keyword, value);
    }
}