package com.leafy.util;

public class LogMasker {

    public static String mask(String content) {
        if (content == null || content.length() <= 3) {
            return "***";
        }
        return content.substring(0, 3) + "****" + (content.length() > 7 ? content.substring(content.length() - 2) : "");
    }
}
