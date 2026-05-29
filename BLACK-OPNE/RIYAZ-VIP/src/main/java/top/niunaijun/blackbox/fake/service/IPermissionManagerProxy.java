package top.niunaijun.blackbox.fake.service;

import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;

import java.lang.reflect.Field;

import black.android.app.BRActivityThread;
import black.android.app.BRContextImpl;
import black.android.os.BRServiceManager;
import black.android.permission.BRIPermissionManagerStub;

import top.niunaijun.blackbox.BlackBoxCore;
import top.niunaijun.blackbox.fake.hook.BinderInvocationStub;
import top.niunaijun.blackbox.fake.service.base.PkgMethodProxy;
import top.niunaijun.blackbox.fake.service.base.ValueMethodProxy;
import top.niunaijun.blackbox.utils.compat.BuildCompat;

/**
 * Fixed for Android 10–15
 * No mid-game crash
 */
public class IPermissionManagerProxy extends BinderInvocationStub {
    public static final String TAG = "IPermissionManagerProxy";

    private static final String P = "permissionmgr";

    public IPermissionManagerProxy() {
        super(BRServiceManager.get().getService(P));
    }

    @Override
    protected Object getWho() {
        return BRIPermissionManagerStub.get().asInterface(BRServiceManager.get().getService(P));
    }

    @Override
    protected void inject(Object baseInvocation, Object proxyInvocation) {
        replaceSystemService(P);
        try {
            BRActivityThread.getWithException()._set_sPermissionManager(proxyInvocation);
        } catch (Throwable e) {
            Log.w(TAG, "Unable to replace ActivityThread.sPermissionManager", e);
        }

        Object systemContext = BRActivityThread.get(BlackBoxCore.mainThread()).getSystemContext();
        PackageManager packageManager = BRContextImpl.get(systemContext).mPackageManager();
        if (packageManager != null) {
            installApplicationPackagePermissionManager(systemContext, packageManager, proxyInvocation);
        }
    }

    private void installApplicationPackagePermissionManager(Object systemContext, PackageManager packageManager, Object proxyInvocation) {
        try {
            Field permissionManagerField = findField(Class.forName("android.app.ApplicationPackageManager"), "mPermissionManager");
            permissionManagerField.setAccessible(true);
            Class<?> fieldType = permissionManagerField.getType();
            if (proxyInvocation != null && fieldType.isInstance(proxyInvocation)) {
                permissionManagerField.set(packageManager, proxyInvocation);
                Log.d(TAG, "Installed permission binder proxy into ApplicationPackageManager.mPermissionManager");
                return;
            }

            Object typedPermissionManager = getTypedPermissionManager(systemContext, permissionManagerField, packageManager, fieldType);
            if (typedPermissionManager != null && fieldType.isInstance(typedPermissionManager)) {
                permissionManagerField.set(packageManager, typedPermissionManager);
                Log.d(TAG, "Kept typed PermissionManager wrapper for ApplicationPackageManager.mPermissionManager");
            } else {
                String proxyType = proxyInvocation == null ? "null" : proxyInvocation.getClass().getName();
                Log.w(TAG, "Skipping ApplicationPackageManager.mPermissionManager hook because field type "
                        + fieldType.getName() + " is not compatible with " + proxyType);
            }
        } catch (Throwable e) {
            Log.w(TAG, "Unable to install ApplicationPackageManager permission hook", e);
        }
    }


    private Field findField(Class<?> type, String name) throws NoSuchFieldException {
        for (Class<?> clazz = type; clazz != null; clazz = clazz.getSuperclass()) {
            try {
                return clazz.getDeclaredField(name);
            } catch (NoSuchFieldException ignored) {
                // Continue walking the hierarchy.
            }
        }
        throw new NoSuchFieldException(name);
    }

    private Object getTypedPermissionManager(Object systemContext, Field permissionManagerField,
                                             PackageManager packageManager, Class<?> fieldType)
            throws IllegalAccessException {
        Object currentPermissionManager = permissionManagerField.get(packageManager);
        if (currentPermissionManager != null && fieldType.isInstance(currentPermissionManager)) {
            return currentPermissionManager;
        }
        if ("android.permission.PermissionManager".equals(fieldType.getName())
                && systemContext instanceof Context) {
            return ((Context) systemContext).getSystemService(fieldType);
        }
        return null;
    }

    @Override
    protected void onBindMethod() {
        super.onBindMethod();
        addMethodHook(new ValueMethodProxy("addPermissionAsync", true));
        addMethodHook(new ValueMethodProxy("addPermission", true));
        addMethodHook(new ValueMethodProxy("performDexOpt", true));
        addMethodHook(new ValueMethodProxy("performDexOptIfNeeded", false));
        addMethodHook(new ValueMethodProxy("performDexOptSecondary", true));
        addMethodHook(new ValueMethodProxy("addOnPermissionsChangeListener", 0));
        addMethodHook(new ValueMethodProxy("removeOnPermissionsChangeListener", 0));
        addMethodHook(new ValueMethodProxy("checkDeviceIdentifierAccess", false));
        addMethodHook(new PkgMethodProxy("shouldShowRequestPermissionRationale"));
        if (BuildCompat.isOreo()) {
            addMethodHook(new ValueMethodProxy("notifyDexLoad", 0));
            addMethodHook(new ValueMethodProxy("notifyPackageUse", 0));
            addMethodHook(new ValueMethodProxy("setInstantAppCookie", false));
            addMethodHook(new ValueMethodProxy("isInstantApp", false));
        }
    }

    @Override
    public boolean isBadEnv() {
        return false;
    }

}
