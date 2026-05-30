package top.niunaijun.blackbox.utils.compat;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import java.util.Locale;

import top.niunaijun.blackbox.core.env.AppSystemEnv;

/**
 * Helpers for OAuth based login flows that intentionally cross the virtual/real
 * boundary. Facebook login commonly leaves the virtual app to Chrome Custom Tabs
 * or the Facebook app, then returns through an app-specific callback scheme.
 *
 * Keep these checks narrow so normal implicit intents continue to resolve inside
 * OneBox and only browser/Facebook OAuth traffic is forwarded to host packages.
 */
public final class OAuthIntentHelper {
    private static final String CUSTOM_TABS_ACTION = "android.support.customtabs.action.CustomTabsService";
    private static final String ANDROIDX_CUSTOM_TABS_ACTION = "androidx.browser.customtabs.action.CustomTabsService";

    private OAuthIntentHelper() {
    }

    public static boolean targetsOpenPackage(Intent intent) {
        if (intent == null) return false;
        ComponentName componentName = intent.getComponent();
        if (AppSystemEnv.isOpenPackage(componentName)) return true;
        return AppSystemEnv.isOpenPackage(intent.getPackage());
    }

    public static boolean targetsBrowserPackage(Intent intent) {
        if (intent == null) return false;
        ComponentName componentName = intent.getComponent();
        if (AppSystemEnv.isBrowserPackage(componentName)) return true;
        return AppSystemEnv.isBrowserPackage(intent.getPackage());
    }

    public static boolean targetsFacebookPackage(Intent intent) {
        if (intent == null) return false;
        ComponentName componentName = intent.getComponent();
        if (AppSystemEnv.isFacebookPackage(componentName)) return true;
        return AppSystemEnv.isFacebookPackage(intent.getPackage());
    }

    public static boolean isCustomTabsService(Intent intent) {
        if (intent == null) return false;
        String action = intent.getAction();
        return CUSTOM_TABS_ACTION.equals(action) || ANDROIDX_CUSTOM_TABS_ACTION.equals(action);
    }

    /**
     * Host resolver should be used for browser, Custom Tabs and Facebook SSO
     * discovery so virtual apps can see host-installed trusted handlers.
     */
    public static boolean shouldUseHostResolver(Intent intent) {
        return targetsOpenPackage(intent)
                || isCustomTabsService(intent)
                || isExternalBrowserAuthIntent(intent)
                || isFacebookPlatformIntent(intent);
    }

    /**
     * Intents that start Facebook auth in browser/custom tabs should not be
     * forced back into the current virtual package by ActivityManager fallback.
     */
    public static boolean shouldBypassVirtualFallback(Intent intent) {
        return targetsBrowserPackage(intent)
                || isExternalBrowserAuthIntent(intent)
                || isIntentUri(intent)
                || isCustomTabsService(intent);
    }

    /**
     * Callback intents should be tried against the current virtual package first
     * so FacebookActivity/CallbackManager inside the virtual app receives them.
     */
    public static boolean isFacebookOAuthCallback(Intent intent) {
        if (intent == null) return false;
        Uri data = intent.getData();
        if (data == null) return false;

        String scheme = lower(data.getScheme());
        String host = lower(data.getHost());
        String path = lower(data.getPath());
        String dataString = lower(data.toString());

        if ("fbconnect".equals(scheme)) return true;
        if (scheme != null && scheme.matches("fb\\d+")) return true;
        if (isFacebookHost(host) && path != null && path.contains("/connect/login_success")) return true;
        return dataString != null && dataString.contains("facebook.com/connect/login_success");
    }

    public static boolean isExternalBrowserAuthIntent(Intent intent) {
        if (intent == null) return false;
        if (!Intent.ACTION_VIEW.equals(intent.getAction())) return false;
        Uri data = intent.getData();
        if (data == null) return false;

        String scheme = lower(data.getScheme());
        String host = lower(data.getHost());
        String dataString = lower(data.toString());

        if (isIntentUri(intent)) return true;
        if (!"http".equals(scheme) && !"https".equals(scheme)) return false;
        if (isFacebookHost(host)) return true;
        return dataString != null
                && (dataString.contains("facebook.com")
                || dataString.contains("fbconnect")
                || dataString.contains("dialog/oauth")
                || dataString.contains("oauth"));
    }

    public static boolean isFacebookPlatformIntent(Intent intent) {
        if (intent == null) return false;
        String action = intent.getAction();
        if (action != null && action.startsWith("com.facebook.platform.")) return true;
        ComponentName componentName = intent.getComponent();
        return AppSystemEnv.isFacebookPackage(componentName) || AppSystemEnv.isFacebookPackage(intent.getPackage());
    }

    public static boolean isIntentUri(Intent intent) {
        if (intent == null || intent.getData() == null) return false;
        return "intent".equals(lower(intent.getData().getScheme()));
    }

    private static boolean isFacebookHost(String host) {
        return !TextUtils.isEmpty(host)
                && (host.equals("facebook.com")
                || host.endsWith(".facebook.com")
                || host.equals("fb.com")
                || host.endsWith(".fb.com"));
    }

    private static String lower(String value) {
        return value == null ? null : value.toLowerCase(Locale.US);
    }
}
