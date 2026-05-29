package com.onecore.loader.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;

public final class StartupPermissionHelper {
    private static final int REQUEST_RUNTIME_PERMISSIONS = 7201;
    private static final long SPECIAL_PERMISSION_RETRY_MS = 6000L;
    private static final String PREFS_NAME = "startup_permissions";
    private static final String KEY_LAST_SPECIAL_PERMISSION = "last_special_permission";
    private static final String KEY_LAST_SPECIAL_PERMISSION_TIME = "last_special_permission_time";

    private static final String SPECIAL_ALL_FILES = "all_files";
    private static final String SPECIAL_OVERLAY = "overlay";
    private static final String SPECIAL_INSTALL_PACKAGES = "install_packages";

    private StartupPermissionHelper() {
    }

    public static boolean ensureCorePermissions(Activity activity) {
        boolean granted = hasCorePermissions(activity);
        if (!granted) {
            requestAllStartupPermissions(activity);
            Toast.makeText(activity, "Please allow loader permissions, then try again.", Toast.LENGTH_LONG).show();
        }
        return granted;
    }

    public static boolean ensureStoragePermission(Activity activity) {
        boolean granted = hasStoragePermission(activity);
        if (!granted) {
            requestAllStartupPermissions(activity);
            Toast.makeText(activity, "Storage permission is required to copy OBB files.", Toast.LENGTH_LONG).show();
        }
        return granted;
    }

    public static boolean hasCorePermissions(Context context) {
        return hasRuntimePermissions(context)
                && hasStoragePermission(context)
                && hasOverlayPermission(context)
                && hasInstallPackagesPermission(context);
    }

    public static boolean hasStoragePermission(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return Environment.isExternalStorageManager();
        }
        return ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }

    public static void requestAllStartupPermissions(Activity activity) {
        if (!hasRuntimePermissions(activity)) {
            requestRuntimePermissions(activity);
            return;
        }

        if (!hasStoragePermission(activity)) {
            openSpecialPermission(activity, SPECIAL_ALL_FILES, Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
            return;
        }

        if (!hasOverlayPermission(activity)) {
            openSpecialPermission(activity, SPECIAL_OVERLAY, Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
            return;
        }

        if (!hasInstallPackagesPermission(activity)) {
            openSpecialPermission(activity, SPECIAL_INSTALL_PACKAGES, Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
        }
    }

    private static boolean hasRuntimePermissions(Context context) {
        return getMissingRuntimePermissions(context).isEmpty();
    }

    private static void requestRuntimePermissions(Activity activity) {
        List<String> missingPermissions = getMissingRuntimePermissions(activity);
        if (!missingPermissions.isEmpty()) {
            ActivityCompat.requestPermissions(activity,
                    missingPermissions.toArray(new String[0]),
                    REQUEST_RUNTIME_PERMISSIONS);
        }
    }

    private static List<String> getMissingRuntimePermissions(Context context) {
        List<String> permissions = new ArrayList<>();
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            addIfMissing(context, permissions, Manifest.permission.READ_EXTERNAL_STORAGE);
        }
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            addIfMissing(context, permissions, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            addIfMissing(context, permissions, Manifest.permission.POST_NOTIFICATIONS);
        }
        return permissions;
    }

    private static void addIfMissing(Context context, List<String> permissions, String permission) {
        if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(permission);
        }
    }

    private static boolean hasOverlayPermission(Context context) {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(context);
    }

    private static boolean hasInstallPackagesPermission(Context context) {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.O || context.getPackageManager().canRequestPackageInstalls();
    }

    private static void openSpecialPermission(Activity activity, String permissionKey, String action) {
        if (wasSpecialPermissionOpenedRecently(activity, permissionKey)) {
            return;
        }
        rememberSpecialPermissionOpen(activity, permissionKey);

        Intent intent = new Intent(action, Uri.parse("package:" + activity.getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            activity.startActivity(intent);
        } catch (Exception e) {
            FLog.error("Unable to open permission screen: " + action, e);
            try {
                activity.startActivity(new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:" + activity.getPackageName())));
            } catch (Exception fallbackError) {
                FLog.error("Unable to open app settings for permissions", fallbackError);
            }
        }
    }

    private static boolean wasSpecialPermissionOpenedRecently(Context context, String permissionKey) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        String lastPermission = prefs.getString(KEY_LAST_SPECIAL_PERMISSION, "");
        long lastTime = prefs.getLong(KEY_LAST_SPECIAL_PERMISSION_TIME, 0L);
        return permissionKey.equals(lastPermission)
                && System.currentTimeMillis() - lastTime < SPECIAL_PERMISSION_RETRY_MS;
    }

    private static void rememberSpecialPermissionOpen(Context context, String permissionKey) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_LAST_SPECIAL_PERMISSION, permissionKey)
                .putLong(KEY_LAST_SPECIAL_PERMISSION_TIME, System.currentTimeMillis())
                .apply();
    }
}
