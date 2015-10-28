package com.example.gcielniak.tangoscanner;

import java.util.ArrayList;

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
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.CompoundButton;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

/**
 * Main Activity for the Tango Java Quickstart. Demonstrates establishing a
 * connection to the {@link Tango} service and printing the {@link TangoPoseData}
 * data to the LogCat. Also demonstrates Tango lifecycle management through
 * {@link TangoConfig}.
 */
public class MainActivity extends Activity {
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

    ScanLogger scan_logger;
    WifiScanner wifi_scanner;
    BluetoothScanner bluetooth_scanner;
    boolean tango_init_phase = false;
    OnScanListener listener;
    TangoPoseData current_pose;

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

        scan_logger = new ScanLogger();

        //WIFI stuff
        wifi_scanner = new WifiScanner(this, scan_logger);

        //BT stuff
        bluetooth_scanner = new BluetoothScanner(scan_logger);

        listener = scan_logger;
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

        if (!tango_init_phase)
            startToggleButton.setChecked(false);
        else
            tango_init_phase = false;
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

                wifi_scanner.UpdatePose(pose);
                bluetooth_scanner.UpdatePose(pose);
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

                if (!btToggleButton.isChecked() && !wifiToggleButton.isChecked()) {
                    Scan scan = new Scan();
                    scan.mac_address = "";
                    scan.device_type = DeviceType.NO_DEVICE;
                    scan.translation = current_pose.translation;
                    scan.rotation = current_pose.rotation;
                    scan.timestamp = (long)(current_pose.timestamp*1000);

                    listener.onScan(scan);
                }

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

    public class StartOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                //tango
                if ((mTango != null) && !mIsTangoServiceConnected) {
                    startActivityForResult(
                            Tango.getRequestPermissionIntent(Tango.PERMISSIONTYPE_MOTION_TRACKING),
                            Tango.TANGO_INTENT_ACTIVITYCODE);
                    tango_init_phase = true;
                }

                scan_logger.Start();

                //wifi
                if (wifiToggleButton.isChecked())
                    wifi_scanner.Start();

                //bluetooth
                if (btToggleButton.isChecked())
                    bluetooth_scanner.Start();

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

                scan_logger.Stop(MainActivity.this);

                //wifi
                if (wifiToggleButton.isChecked())
                    wifi_scanner.Stop();

                //bluetooth
                if (btToggleButton.isChecked())
                    bluetooth_scanner.Stop();
            }
        }
    }

    public class WifiOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                if (!wifi_scanner.IsEnabled()) {
                    Toast.makeText(getApplicationContext(), "WiFi not enabled!",
                            Toast.LENGTH_SHORT).show();
                    buttonView.setChecked(false);
                }
                else if (startToggleButton.isChecked())
                    wifi_scanner.Start();
            } else {
                if (startToggleButton.isChecked())
                    wifi_scanner.Stop();
            }
        }
    }

    public class BTOnCheckedChangeListener implements CompoundButton.OnCheckedChangeListener {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            if (isChecked) {
                if (!bluetooth_scanner.IsEnabled()) {
                    Toast.makeText(getApplicationContext(), "Bluetooth not enabled!",
                            Toast.LENGTH_SHORT).show();
                    buttonView.setChecked(false);
                }
                else if (startToggleButton.isChecked()) {
                    bluetooth_scanner.Start();
                }
            } else {
                if (startToggleButton.isChecked())
                    bluetooth_scanner.Stop();
            }
        }
    }
}
