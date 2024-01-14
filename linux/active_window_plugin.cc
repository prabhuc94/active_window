#include "include/active_window/active_window_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <string>
#include <stdexcept>

#include "active_window_plugin_private.h"

#define ACTIVE_WINDOW_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), active_window_plugin_get_type(), \
                              ActiveWindowPlugin))

std::string exec(const char* cmd) {
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(cmd, "r");
    if (!pipe) throw std::runtime_error("popen() failed!");
    try {
        while (fgets(buffer, sizeof buffer, pipe) != NULL) {
            result += buffer;
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}

struct _ActiveWindowPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(ActiveWindowPlugin, active_window_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void active_window_plugin_handle_method_call(
    ActiveWindowPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getActiveWindowInfo") == 0) {
        struct utsname uname_data = {};
        uname(&uname_data);
        std::string xprops = exec("xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)");
        g_autofree gchar *version = g_strdup_printf("%s",xprops.c_str());
        g_autoptr(FlValue) result = fl_value_new_string(version);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        // struct utsname uname_data = {};
        // uname(&uname_data);
        // g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
        // g_autoptr(FlValue) result = fl_value_new_string(version);
        // response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void active_window_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(active_window_plugin_parent_class)->dispose(object);
}

static void active_window_plugin_class_init(ActiveWindowPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = active_window_plugin_dispose;
}

static void active_window_plugin_init(ActiveWindowPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  ActiveWindowPlugin* plugin = ACTIVE_WINDOW_PLUGIN(user_data);
  active_window_plugin_handle_method_call(plugin, method_call);
}

void active_window_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  ActiveWindowPlugin* plugin = ACTIVE_WINDOW_PLUGIN(
      g_object_new(active_window_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "active_window",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
