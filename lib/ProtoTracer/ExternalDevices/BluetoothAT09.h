#pragma once

#include <Arduino.h>
#include <vector>

class ProtogenProject; // Forward declaration

class BluetoothAT09 {
    private:
        // Pointer to the main project instance
        ProtogenProject* project = nullptr;
        // Buffer to store received data
        String receivedDataBuffer = "";
        void GetProtoData();
        void HandleCommand(const String& command, const String& value);
        std::vector<String> splitString(const String& string, char delimiter);

    public:
        BluetoothAT09();
        void SendDataToPhone(const String& message);
        void Initialize(ProtogenProject* proj);
        void Update();
};