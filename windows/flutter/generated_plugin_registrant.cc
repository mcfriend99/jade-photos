//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <file_selector_windows/file_selector_windows.h>
#include <flutter_lite_camera/flutter_lite_camera_plugin_c_api.h>
#include <image_compression_flutter/image_compression_flutter_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  FlutterLiteCameraPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLiteCameraPluginCApi"));
  ImageCompressionFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageCompressionFlutterPlugin"));
}
