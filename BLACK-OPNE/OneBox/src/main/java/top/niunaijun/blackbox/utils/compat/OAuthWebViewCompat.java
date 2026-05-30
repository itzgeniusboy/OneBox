package top.niunaijun.blackbox.utils.compat;

import android.annotation.SuppressLint;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.webkit.CookieManager;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.Locale;

import top.niunaijun.blackbox.utils.Slog;

/**
 * Shared WebView hardening for OAuth fallback screens.
 *
 * Facebook strongly prefers app/browser/Custom Tab login. When a virtual app
 * falls back to WebView, cookies, DOM storage and redirects must behave like a
 * real browser or the login session is often dropped before CallbackManager sees
 * the result.
 */
public final class OAuthWebViewCompat {
    private static final String TAG = "OAuthWebViewCompat";
    private static final String DESKTOP_CHROME_UA = "Mozilla/5.0 (Linux; Android 10) "
            + "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

    private OAuthWebViewCompat() {
    }

    @SuppressLint("SetJavaScriptEnabled")
    public static void configure(WebView webView) {
        if (webView == null) return;

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);
        settings.setSupportMultipleWindows(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE);
        }

        String currentUa = settings.getUserAgentString();
        if (TextUtils.isEmpty(currentUa) || currentUa.toLowerCase(Locale.US).contains("wv")) {
            settings.setUserAgentString(DESKTOP_CHROME_UA);
        }

        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.setAcceptThirdPartyCookies(webView, true);
            cookieManager.flush();
        }
    }

    public static WebViewClient createOAuthWebViewClient(final Context context) {
        return new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return handleUrl(context, view, url);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Uri uri = request == null ? null : request.getUrl();
                return handleUrl(context, view, uri == null ? null : uri.toString());
            }
        };
    }

    private static boolean handleUrl(Context context, WebView webView, String url) {
        if (TextUtils.isEmpty(url)) return false;
        Uri uri = Uri.parse(url);
        String scheme = uri.getScheme() == null ? "" : uri.getScheme().toLowerCase(Locale.US);

        if ("http".equals(scheme) || "https".equals(scheme)) {
            return false;
        }

        Intent intent;
        try {
            if ("intent".equals(scheme)) {
                intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
            } else {
                intent = new Intent(Intent.ACTION_VIEW, uri);
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            syncCookies(webView);
            return true;
        } catch (ActivityNotFoundException e) {
            Slog.w(TAG, "No activity for OAuth redirect: " + url);
        } catch (Throwable e) {
            Slog.w(TAG, "Unable to dispatch OAuth redirect: " + e.getMessage());
        }
        return false;
    }

    public static void syncCookies(WebView webView) {
        CookieManager cookieManager = CookieManager.getInstance();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.flush();
        }
    }
}
