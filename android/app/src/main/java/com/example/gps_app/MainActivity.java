package com.example.gps_app;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private Intent forService;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        forService = new Intent(this, MyService.class);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),
                "com.example.gps_app.messages")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if(call.method.equals("startService")) {
                            startService();
                            result.success("service started");
                        } else {
                            stopService(forService);
                            result.success("service stopped");
                        }

                    }
                });
    }

    private void startService() {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService);
        } else {
            startService(forService);
        }
    }
}