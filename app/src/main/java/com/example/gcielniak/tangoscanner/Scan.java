package com.example.gcielniak.tangoscanner;

import android.util.Log;

import java.util.Arrays;

/**
 * Created by gcielniak on 10/10/2015.
 */
enum DeviceType {
    BT_BEACON,
    WIFI_AP
};

public class Scan {
    public DeviceType device_type;
    public String name;
    public String mac_address;
    public long timestamp;
    public double value;
    public double[] translation;
    public double[] rotation;
    public UUID uuid;

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
                    " r=" + rotation[0] + " " + rotation[1] + " " + rotation[2] + " " + rotation[3] + " u=" + uuid);
        else
            return new String("WF: t=" + timestamp + " n=\"" + _name + "\" a=" + mac_address + " v=" + value +
                    " p=" + translation[0] + " " + translation[1] + " " + translation[2] +
                    " r=" + rotation[0] + " " + rotation[1] + " " + rotation[2] + " " + rotation[3]);
    }

    public static String byteArrayToHex(byte[] a) {
        StringBuilder sb = new StringBuilder(a.length * 2);
        for(byte b: a)
            sb.append(String.format("%02X", b & 0xff));
        return sb.toString();
    }

    static class UUID {
        byte[] data;
        UUID(byte[] data) { this.data = data; }
        UUID(byte[] data, int major, int minor) {
            byte[] major_minor = new byte[4];
            major_minor[0] = (byte)(major & 0xFF00 >> 8);
            major_minor[1] = (byte)(major & 0xFF);
            major_minor[2] = (byte)(minor & 0xFF00 >> 8);
            major_minor[3] = (byte)(minor & 0xFF);

            this.data = new byte[data.length + major_minor.length];
            System.arraycopy(data, 0, this.data, 0, data.length);
            System.arraycopy(major_minor, 0, this.data, data.length, major_minor.length);
        }

        public boolean Compare(UUID uuid) {
            if ((this.data == null) || (uuid.data == null) || (this.data.length != uuid.data.length))
                return false;

            for (int i = 0; i < this.data.length; i++)
                if (this.data[i] != uuid.data[i])
                    return false;

            return true;
        }

        public String toString() {
            if (data != null)
                return byteArrayToHex(this.data);
            else
                return "";
        }

        public String toStringUUID() {
            if (data != null)
                return byteArrayToHex(Arrays.copyOf(this.data,16));
            else
                return "";
        }

        public String toStringMajor() {
            if (data != null) {
                int major = ((this.data[16] << 8) & 0xFF00) | (this.data[17] & 0xFF);
                return Integer.toString(major);
            }
            else
                return "";
        }

        public String toStringMinor() {
            if (data != null) {
                int major = ((this.data[18] << 8) & 0xFF00) | (this.data[19] & 0xFF);
                return Integer.toString(major);
            }
            else
                return "";
        }
    }
};


