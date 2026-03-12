package com.socialmedia.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
 
public class CloudinaryUtil {
    
    private static Cloudinary cloudinary;

    public static Cloudinary getInstance() {
        if (cloudinary == null) {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", System.getenv("CLOUDINARY_CLOUD_NAME"),
                "api_key", System.getenv("CLOUDINARY_API_KEY"),
                "api_secret", System.getenv("CLOUDINARY_API_SECRET"),
                "secure", true
            ));
        }
        return cloudinary;
    }
}