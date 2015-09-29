package com.example.gcielniak.tangoscanner;


import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.google.atap.tangoservice.Tango;
import com.google.atap.tangoservice.Tango.OnTangoUpdateListener;
import com.google.atap.tangoservice.TangoConfig;
import com.google.atap.tangoservice.TangoCoordinateFramePair;
import com.google.atap.tangoservice.TangoErrorException;
import com.google.atap.tangoservice.TangoEvent;
import com.google.atap.tangoservice.TangoOutOfDateException;
import com.google.atap.tangoservice.TangoPoseData;
import com.google.atap.tangoservice.TangoXyzIjData;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;


enum DeviceType {
    BT_BEACON,
    WIFI_AP
};

class Scan {
    public DeviceType device_type;
    public String name;
    public String mac_address;
    public long timestamp;
    public double value;
    public double[] translation;
    public double[] rotation;

    Scan() {
        translation = new double[3];
        rotation = new double[4];
    }

    public boolean equals(Object o) {
        if (o instanceof Scan)
            return this.mac_address.equals(((Scan) o).mac_address);

        return false;
    }

    @Override
    public String toString() {

        String _name = new String();
        if (name != null)
            _name = name;

        if (device_type == DeviceType.BT_BEACON)
            return new String("BT: t=" + timestamp + " n=\"" + _name + "\" a=" + mac_address + " v=" + value +
                    " p=" + translation[0] + " " + translation[1] + " " + translation[2] +
                    " r=" + rotation[0] + " " + rotation[1] + " " + rotation[2] + " " + rotation[3]);
        else
            return new String("WF: t=" + timestamp + " n=\"" + _name + "\" a=" + mac_address + " v=" + value +
                    " p=" + translation[0] + " " + translation[1] + " " + translation[2] +
                    " r=" + rotation[0] + " " + rotation[1] + " " + rotation[2] + " " + rotation[3]);
    }
};

/**
 * Main Activity for the Tango Java Quickstart. Demonstrates establishing a
 * connection to the {@link Tango} service and printing the {@link TangoPoseData}
 * data to the LogCat. Also demonstrates Tango lifecycle management through
 * {@link TangoConfig}.
 */
public class MainActivity extends Activity {
    private List<Scan> current_scan;

    private static final String TAG = MainActivity.class.getSimpleName();
    private static final String sTranslationFormat = "Translation: %.2f, %.2f, %.2f";
    private static final String sRotationFormat = "Rotation: %.2f, %.2f, %.2f, %.2f";

    private TextView mTranslationTextView;
    private TextView mRotationTextView;
    private ToggleButton startToggleButton;
    private ToggleButton wifiToggleButton;
    private ToggleButton btToggleButton;

    private Tango mTango;
    private TangoConfig mConfig;
    private boolean mIsTangoServiceConnected;
    private boolean mIsProcessing = false;

    WifiManager wifi;
    WifiScanReceiver wifiScanReceiver;
    TangoPoseData current_pose;
    BLeScanCallback bLEScanCallback;
    BluetoothAdapter mBluetoothAdapter;
    File log_file;
    FileWriter log_file_writer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTranslationTextView = (TextView) findViewById(R.id.translation_text_view);
        mRotationTextView = (TextView) findViewById(R.id.rotation_text_view);
        startToggleButton = (ToggleButton) findViewById(R.id.start_toogle_button);
        wifiToggleButton = (ToggleButton) findViewById(R.id.wifi_toogle_button);
        btToggleButton = (ToggleButton) findViewById(R.id.bt_toogle_button);
        startToggleButton.setOnCheckedChangeListener(new StartOnCheckedChangeListener());
        wifiToggleButton.setOnCheckedChangeListener(new WifiOnCheckedChangeListener());
        btToggleButton.setOnCheckedChangeListener(new BTOnCheckedChangeListener());

        current_scan = new ArrayList<Scan>();

        // Instantiate Tango client
        try {
            mTango = new Tango(this);
            // Set up Tango configuration for motion tracking
            // If you want to use other APIs, add more appropriate to the config
            // like: mConfig.putBoolean(TangoConfig.KEY_BOOLEAN_DEPTH, true)
            mConfig = mTango.getConfig(TangoConfig.CONFIG_TYPE_CURRENT);
            mConfig.putBoolean(TangoConfig.KEY_BOOLEAN_MOTIONTRACKING, true);
        } catch (Throwable exc) {
            Log.i(TAG, "Could not find the Tango");
        }

        //WIFI stuff
        wifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        if (wifi != null) {
            wifiScanReceiver = new WifiScanReceiver();
        }

        //BT stuff
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter != null) {
            bLEScanCallback = new BLeScanCallback();
        }

        current_pose = new TangoPoseData();

    }

    @Override
    protected void onResume() {
        super.onResume();
        // Lock the Tango configuration and reconnect to the service each time
        // the app
        // is brought to the foreground.
    }

    @Override
    protected void onPause() {
        super.onPause();
        // When the app is pushed to the background, unlock the Tango
        // configuration and disconnect
        // from the service so that other apps will behave properly.

        startToggleButton.setChecked(false);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // Check which request we're responding to
        if (requestCode == Tango.TANGO_INTENT_ACTIVITYCODE) {
            // Make sure the request was successful
            if (resultCode == RESULT_CANCELED) {
                Toast.makeText(this,
                        "This app requires Motion Tracking permission!",
                        Toast.LENGTH_LONG).show();
                finish();
                return;
            }

            try {
                setTangoListeners();
            } catch (TangoErrorException e) {
                Toast.makeText(getApplicationContext(), "Tango Error! Restart the app!",
                        Toast.LENGTH_SHORT).show();
            }

            try {
                mTango.connect(mConfig);
                mIsTangoServiceConnected = true;
            }
            catch (TangoOutOfDateException e) {
                Toast.makeText(getApplicationContext(), "Tango Service out of date!",
                        Toast.LENGTH_SHORT).show();
            }
            catch (TangoErrorException e) {
                Toast.makeText(getApplicationContext(), "Tango Error! Restart the app!",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void setTangoListeners() {
        // Select coordinate frame pairs
        ArrayList<TangoCoordinateFramePair> framePairs = new ArrayList<TangoCoordinateFramePair>();
        framePairs.add(new TangoCoordinateFramePair(
                TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE,
                TangoPoseData.COORDINATE_FRAME_DEVICE));

        // Add a listener for Tango pose data
        mTango.connectListener(framePairs, new OnTangoUpdateListener() {

            @SuppressLint("DefaultLocale")
            @Override
            public void onPoseAvailable(TangoPoseData pose) {
                if (mIsProcessing) {
                    return;
                }
                mIsProcessing = true;

                current_pose = pose;

                // Format Translation and Rotation data
                final String translationMsg = String.format(sTranslationFormat,
                        pose.translation[0], pose.translation[1],
                        pose.translation[2]);
                final String rotationMsg = String.format(sRotationFormat,
                        pose.rotation[0], pose.rotation[1], pose.rotation[2],
                        pose.rotation[3]);

                // Output to LogCat
                String logMsg = translationMsg + " | " + rotationMsg;
//                Log.i(TAG, logMsg);

                // Display data in TextViews. This must be done inside a
                // runOnUiThread call because
                // it affects the UI, which will cause an error if performed
                // from the Tango
                // service thread
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mTranslationTextView.setText(translationMsg);
                        mRotationTextView.setText(rotationMsg);
                        mIsProcessing = false;
                    }
                });
            }

            @Override
            public void onXyzIjAvailable(TangoXyzIjData arg0) {
                // Ignoring XyzIj data
            }

            @Override
            public void onTangoEvent(TangoEvent arg0) {
                // Ignoring TangoEvents
            }

            @Override
            public void onFrameAvailable(int arg0) {
                // Ignoring onFrameAvailable Events

            }

        });
    }

    private class WifiScanReceiver extends BroadcastReceiver {
        public void onReceive(Context c, Intent intent) {
            List<ScanResult> wifiScanList = wifi.getScanResults();

            for (int i = 0; i < wifiScanList.size(); i++) {
                ScanResult result = wifiScanList.get(i);

                Scan scan = new Scan();
                scan.device_type = DeviceType.WIFI_AP;
                scan.mac_address = result.BSSID.toUpperCase();
                scan.name = result.SSID;
                scan.timestamp = result.timestamp;
                scan.value = (double) result.level;
                scan.translation = current_pose.translation;
                scan.rotation = current_pose.rotation;

                int indx = current_scan.indexOf(scan);
                if (indx != -1) {
                    if (current_scan.get(indx).timestamp == scan.timestamp)
                        continue;
                    current_scan.remove(indx);
                }
                current_scan.add(scan);

                Log.i(TAG, scan.toString());

                if (log_file_writer != null) {
                    try {
                        log_file_writer.write(scan + "\n");
                    } catch (IOException exc) {
                        Log.i(TAG, "Error writing to file.");
                    }
                }
            }
            wifi.startScan();
        }
    }

    private class BLeScanCallback implements BluetoothAdapter.LeScanCallback {
        @Override
        public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {

            Scan scan = new Scan();
            scan.device_type = DeviceType.BT_BEACON;
            scan.mac_address = device.getAddress();
            scan.name = device.getName();
            scan.timestamp = SystemClock.elapsedRealtimeNanos() / 1000;
            scan.value = (double) rssi;
            scan.translation = current_pose.translation;
            scan.rotation = current_pose.rotation;

            int indx = current_scan.indexOf(scan);
            if (indx != -1) {
                current_scan.remove(indx);
            }
            current_scan.add(scan);

            Log.i(TAG, scan.toString());
            if (log_file_writer != null) {
                try {
                    log_file_writer.write(scan + "\n");
                } catch (IOException exc) {
                    Log.i(TAG, "Error writing to file.");
                }
            }
        }
    }

    public class StartOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                //tango
                if ((mTango != null) && !mIsTangoServiceConnected) {
                    startActivityForResult(
                            Tango.getRequestPermissionIntent(Tango.PERMISSIONTYPE_MOTION_TRACKING),
                            Tango.TANGO_INTENT_ACTIVITYCODE);
                }

                //log file
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd'T'HHmmss.ssss");
                    Date current_date = new Date();
                    log_file = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                            "wifi_bt_log_" + sdf.format(current_date) + ".txt");
                    log_file_writer = new FileWriter(log_file, false);
                    log_file_writer.write(sdf.format(current_date) + "=" + current_date.getTime() * 1000 + '\n');
                } catch (IOException exc) {
                    Log.i("TAG", "Error opening file: " + log_file.getAbsolutePath());
                }

                //wifi
                if (wifiToggleButton.isChecked()) {
                    registerReceiver(wifiScanReceiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
                    wifi.startScan();
                }

                //bluetooth
                if (btToggleButton.isChecked())
                    mBluetoothAdapter.startLeScan(bLEScanCallback);
            } else {
                //tango
                if (mTango != null) {
                    try {
                        mTango.disconnect();
                        mIsTangoServiceConnected = false;
                    }
                    catch (TangoErrorException e) {
                        Toast.makeText(getApplicationContext(), "Tango Error!",
                                Toast.LENGTH_SHORT).show();
                    }
                }

                //log file
                try {
                    log_file_writer.close();
                } catch (IOException exc) {
                    Log.i("TAG", "Error opening the file: " + log_file.getAbsolutePath());
                }

                MediaScannerConnection.scanFile(MainActivity.this,
                        new String[]{log_file.getAbsolutePath()}, null,
                        new MediaScannerConnection.OnScanCompletedListener() {

                            public void onScanCompleted(String path, Uri uri) {
                                Log.i("TAG", "Finished scanning " + path);
                            }
                        });

                //wifi
                if (wifiToggleButton.isChecked())
                    unregisterReceiver(wifiScanReceiver);

                //bluetooth
                if (btToggleButton.isChecked())
                    mBluetoothAdapter.stopLeScan(bLEScanCallback);
            }
        }
    }

    public class WifiOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                if (startToggleButton.isChecked()) {
                    registerReceiver(wifiScanReceiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
                    wifi.startScan();
                }
            } else {
                if (startToggleButton.isChecked())
                    unregisterReceiver(wifiScanReceiver);
            }
        }
    }

    public class BTOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                if (startToggleButton.isChecked())
                    mBluetoothAdapter.startLeScan(bLEScanCallback);
            } else {
                if (startToggleButton.isChecked())
                    mBluetoothAdapter.stopLeScan(bLEScanCallback);
            }
        }
    }
}
