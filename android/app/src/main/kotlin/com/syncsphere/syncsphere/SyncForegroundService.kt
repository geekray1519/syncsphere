package com.syncsphere.syncsphere

import android.app.Service
import android.content.Intent
import android.os.IBinder

class SyncForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // TODO: Implement foreground sync service
        return START_NOT_STICKY
    }
}
