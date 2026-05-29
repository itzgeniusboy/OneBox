package com.onecore.loader.utils;

import android.content.Context;
import android.os.Environment;
import android.util.Log;

import com.onecore.loader.BuildConfig;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class FLog {
    public static final String TAG = FLog.class.getSimpleName();
    private static final String LOG_DIR_NAME = "OneCoreEngine";
    private static final String LOG_FILE_NAME = "loader-debug.log";
    private static final Object FILE_LOCK = new Object();
    private static final SimpleDateFormat LOG_DATE_FORMAT =
            new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US);

    private static Context applicationContext;

    public static void init(Context context) {
        if (context != null) {
            applicationContext = context.getApplicationContext();
            info("Debug log file: " + getDownloadLogFile().getAbsolutePath());
        }
    }

    public static void debug(String msg) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, msg);
        }
        writeToDownloadLog("DEBUG", msg);
    }

    public static void info(String msg) {
        if (BuildConfig.DEBUG) {
            Log.i(TAG, msg);
        }
        writeToDownloadLog("INFO", msg);
    }

    public static void warning(String msg) {
        if (BuildConfig.DEBUG) {
            Log.w(TAG, msg);
        }
        writeToDownloadLog("WARN", msg);
    }

    public static void error(String msg) {
        if (BuildConfig.DEBUG) {
            Log.e(TAG, msg);
        }
        writeToDownloadLog("ERROR", msg);
    }

    public static void error(String msg, Throwable throwable) {
        if (BuildConfig.DEBUG) {
            Log.e(TAG, msg, throwable);
        }
        writeToDownloadLog("ERROR", msg + "\n" + Log.getStackTraceString(throwable));
    }

    private static void writeToDownloadLog(String level, String msg) {
        synchronized (FILE_LOCK) {
            FileWriter writer = null;
            try {
                File logFile = getDownloadLogFile();
                File parent = logFile.getParentFile();
                if (parent != null && !parent.exists() && !parent.mkdirs()) {
                    Log.w(TAG, "Unable to create log directory: " + parent.getAbsolutePath());
                    return;
                }

                writer = new FileWriter(logFile, true);
                writer.append(LOG_DATE_FORMAT.format(new Date()))
                        .append(" ")
                        .append(level)
                        .append("/")
                        .append(TAG)
                        .append(": ")
                        .append(msg == null ? "null" : msg)
                        .append('\n');
            } catch (IOException e) {
                Log.w(TAG, "Unable to write debug log file", e);
            } finally {
                if (writer != null) {
                    try {
                        writer.close();
                    } catch (IOException e) {
                        Log.w(TAG, "Unable to close debug log file", e);
                    }
                }
            }
        }
    }

    public static File getDownloadLogFile() {
        if (applicationContext != null) {
            File externalFilesDir = applicationContext.getExternalFilesDir(null);
            if (externalFilesDir != null) {
                return new File(new File(externalFilesDir, LOG_DIR_NAME), LOG_FILE_NAME);
            }
            return new File(new File(applicationContext.getFilesDir(), LOG_DIR_NAME), LOG_FILE_NAME);
        }

        File downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        return new File(new File(downloadDir, LOG_DIR_NAME), LOG_FILE_NAME);
    }
}
