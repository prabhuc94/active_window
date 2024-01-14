#include "include/active_window/active_window_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "active_window_plugin.h"

void ActiveWindowPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  active_window::ActiveWindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
