#include "active_window_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <stdio.h>
#include "psapi.h"
#include "tlhelp32.h"
#include "Shlwapi.h"
#include <iostream>
#include "atlstr.h"
#include <vector>
#include <locale>
#include <codecvt>
#include <iostream>
#include <Lmcons.h>
#include <ShlObj_core.h>

#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "Psapi.lib")
#pragma comment(lib, "Shell32.lib")


namespace active_window {

// static
void ActiveWindowPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "active_window",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ActiveWindowPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

ActiveWindowPlugin::ActiveWindowPlugin() {}

ActiveWindowPlugin::~ActiveWindowPlugin() {}

    std::string GetExeName2(HWND hwnd) {
        DWORD dwProcId = 0;
        GetWindowThreadProcessId(hwnd, &dwProcId);

        HANDLE hProc = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, dwProcId);
        if (hProc) {
            char buffer[MAX_PATH];
            if (GetProcessImageFileNameA(hProc, buffer, MAX_PATH) > 0) {
                // Extract the executable name from the full path
                std::string fullPath(buffer);
                size_t lastSlash = fullPath.find_last_of('\\');
                if (lastSlash != std::string::npos) {
                    return fullPath.substr(lastSlash + 1);
                }
            }
            CloseHandle(hProc);
        }

        return "";  // Unable to retrieve the executable name
    }

    std::string GetExeName(HWND hwnd)
    {
        char buffer[MAX_PATH] = {0};
        DWORD dwProcId = 0;

        GetWindowThreadProcessId(hwnd, &dwProcId);

        HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ , FALSE, dwProcId);
        if (hProc) {
            if (IsUserAnAdmin()) {
                // If running as administrator, try adjusting token privileges
                HANDLE hToken;
                if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken)) {
                    TOKEN_PRIVILEGES tp;
                    tp.PrivilegeCount = 1;
                    LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &tp.Privileges[0].Luid);
                    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

                    AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);

                    CloseHandle(hToken);
                    if (GetModuleFileNameExA(hProc, 0, buffer, MAX_PATH) == 0) {
                        // Handle error getting executable name
                        std::cerr << "Error getting executable name: " << GetLastError() << std::endl;
                    }
                }
            }
            GetModuleFileNameA((HMODULE)hProc, buffer, MAX_PATH);
            CloseHandle(hProc);
        }
        std::string s(buffer);
        return s;
    }

    std::string ProcessName(HWND hwnd)
    {
        std::string name;
        DWORD ProcessId;
        GetWindowThreadProcessId(hwnd,&ProcessId);
        HANDLE Handle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessId);
        if (Handle) {
            char Buffer[MAX_PATH];
            if (GetModuleFileNameExA(Handle, 0, Buffer, MAX_PATH)) {
                std::string ws = Buffer;
                name = ws;
//                name = utf8_encode(ws);
            }
            else {
                name = "";
            }
            CloseHandle(Handle);
        }

        return name;
    }

    std::wstring GetWindowStringText(HWND hwnd)
    {
        int len = GetWindowTextLengthW(hwnd) + 1;
        std::vector<wchar_t> buf(len);
        GetWindowText(hwnd, &buf[0], len);
        std::wstring wide = &buf[0];
        return wide;
    }

    std::string utf8_encode(const std::wstring &wstr)
    {
        if( wstr.empty() ) return std::string();
        int size_needed = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.size()), NULL, 0, NULL, NULL);
        std::string strTo( size_needed, 0 );
        WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.size()), &strTo[0], size_needed, NULL, NULL);
        return strTo;
    }

void ActiveWindowPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("getActiveWindowInfo") == 0) {

        HWND hwnd=GetForegroundWindow();
        std::string executable = GetExeName2(hwnd);
        std::string exe = ProcessName(hwnd);
        LPCSTR pointer = exe.c_str();
        std::string name = PathFindFileNameA(pointer);

        std::wstring windowTitle = GetWindowStringText(hwnd);
        std::string title = utf8_encode(windowTitle);

        flutter::EncodableMap map;
        map[flutter::EncodableValue("exe")] = name;
        map[flutter::EncodableValue("name")] = executable;
        map[flutter::EncodableValue("title")] = title;

        result->Success(flutter::EncodableValue(map));
    } else {
        result->NotImplemented();
    }
}

}  // namespace active_window
