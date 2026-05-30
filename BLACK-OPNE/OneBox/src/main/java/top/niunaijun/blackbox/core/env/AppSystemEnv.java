package top.niunaijun.blackbox.core.env;

import android.content.ComponentName;
import android.MetaCore.RemoteManager;

import java.util.ArrayList;
import java.util.List;

import top.niunaijun.blackbox.BlackBoxCore;
import org.lsposed.lsparanoid.Obfuscate;

@Obfuscate
public class AppSystemEnv {
    private static final List<String> sSystemPackages = new ArrayList<>();
    private static final List<String> sSuPackages = new ArrayList<>();
    private static final List<String> sXposedPackages = new ArrayList<>();
    private static final List<String> sPreInstallPackages = new ArrayList<>();
    private static final List<String> sBrowserPackages = new ArrayList<>();
    private static final List<String> sFacebookPackages = new ArrayList<>();

    static {
        // Core / AOSP
        addOpenPackage("android");
        addOpenPackage("com.google.android.webview");
        addOpenPackage("com.google.android.webview.dev");
        addOpenPackage("com.google.android.webview.beta");
        addOpenPackage("com.google.android.webview.canary");
        addOpenPackage("com.android.webview");
        // Extra WebView variants (from Code #2)
        addOpenPackage("com.le.android.webview");
        addOpenPackage("com.android.camera");
        addOpenPackage("com.android.talkback");
        addOpenPackage("com.miui.gallery");
        // MIUI / Xiaomi
        addOpenPackage("com.lbe.security.miui");
        addOpenPackage("com.miui.contentcatcher");
        addOpenPackage("com.miui.catcherpatch");
        // Permission Controllers (added)
        addOpenPackage("com.android.permissioncontroller");
        addOpenPackage("com.google.android.permissioncontroller");
        // Google Gboard
        addOpenPackage("com.google.android.inputmethod.latin");
        // Huawei
        addOpenPackage("com.huawei.webview");
        // Oppo / ColorOS & OEM IDs (added)
        addOpenPackage("com.heytap.openid");
        addOpenPackage("com.coloros.safecenter");
        // Samsung / Asus / Lenovo / ZUI / MSA (added)
        addOpenPackage("com.samsung.android.deviceidservice");
        addOpenPackage("com.asus.msa.SupplementaryDID");
        addOpenPackage("com.zui.deviceidservice");
        addOpenPackage("com.mdid.msa");
        // ---- SU / Root apps ----
        sSuPackages.add("com.noshufou.android.su");
        sSuPackages.add("com.noshufou.android.su.elite");
        sSuPackages.add("eu.chainfire.supersu");
        sSuPackages.add("com.koushikdutta.superuser");
        sSuPackages.add("com.thirdparty.superuser");
        sSuPackages.add("com.yellowes.su");
        //sSystemPackages.add(BlackBoxCore.getHostPkg());
        // Magisk (added)
        sSuPackages.add("com.topjohnwu.magisk");
        // ---- Xposed ----
        sXposedPackages.add("de.robv.android.xposed.installer");
        // Twitter / X
        addOpenPackage("com.twitter.android");
        addOpenPackage("com.twitter.android.lite");

        // Browsers exposed to virtual apps for OAuth / Chrome Custom Tabs.
        addBrowserPackage("com.android.chrome");
        addBrowserPackage("com.chrome.beta");
        addBrowserPackage("com.chrome.dev");
        addBrowserPackage("com.google.android.apps.chrome");
        addBrowserPackage("com.sec.android.app.sbrowser");
        addBrowserPackage("com.android.browser");
        addBrowserPackage("com.opera.browser");
        addBrowserPackage("org.mozilla.firefox");

        // Facebook / Messenger packages used by Facebook SDK SSO discovery.
        addFacebookPackage("com.facebook.katana");
        addFacebookPackage("com.facebook.orca");
        addFacebookPackage("com.facebook.lite");
        addFacebookPackage("com.facebook.mlite");
        addFacebookPackage("com.facebook.services");
    }

    private static void addOpenPackage(String packageName) {
        if (!sSystemPackages.contains(packageName)) {
            sSystemPackages.add(packageName);
        }
    }

    private static void addBrowserPackage(String packageName) {
        addOpenPackage(packageName);
        if (!sBrowserPackages.contains(packageName)) {
            sBrowserPackages.add(packageName);
        }
    }

    private static void addFacebookPackage(String packageName) {
        addOpenPackage(packageName);
        if (!sFacebookPackages.contains(packageName)) {
            sFacebookPackages.add(packageName);
        }
    }

    public static boolean isOpenPackage(String packageName) {
        return packageName != null && sSystemPackages.contains(packageName);
    }

    public static boolean isOpenPackage(ComponentName componentName) {
        return componentName != null && isOpenPackage(componentName.getPackageName());
    }

    public static boolean isBrowserPackage(String packageName) {
        return packageName != null && sBrowserPackages.contains(packageName);
    }

    public static boolean isBrowserPackage(ComponentName componentName) {
        return componentName != null && isBrowserPackage(componentName.getPackageName());
    }

    public static boolean isFacebookPackage(String packageName) {
        return packageName != null && sFacebookPackages.contains(packageName);
    }

    public static boolean isFacebookPackage(ComponentName componentName) {
        return componentName != null && isFacebookPackage(componentName.getPackageName());
    }

    public static boolean isBlackPackage(String packageName) {
        if (BlackBoxCore.get().setHideRoot() && sSuPackages.contains(packageName)) {
            return true;
        }
        return RemoteManager.sHideXposed && sXposedPackages.contains(packageName);
    }

    public static List<String> getPreInstallPackages() {
        return sPreInstallPackages;
    }
}
