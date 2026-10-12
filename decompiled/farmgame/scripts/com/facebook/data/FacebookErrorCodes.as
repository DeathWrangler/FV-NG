package com.facebook.data
{
   [Bindable]
   public class FacebookErrorCodes
   {
      
      public static const SERVER_ERROR:Number = -1;
      
      public static const API_EC_SUCCESS:Number = 0;
      
      public static const API_EC_UNKNOWN:Number = 1;
      
      public static const API_EC_SERVICE:Number = 2;
      
      public static const API_EC_METHOD:Number = 3;
      
      public static const API_EC_TOO_MANY_CALLS:Number = 4;
      
      public static const API_EC_BAD_IP:Number = 5;
      
      public static const API_EC_HOST_API:Number = 6;
      
      public static const API_EC_HOST_UP:Number = 7;
      
      public static const API_EC_SECURE:Number = 8;
      
      public static const API_EC_RATE:Number = 9;
      
      public static const API_EC_PERMISSION_DENIED:Number = 10;
      
      public static const API_EC_DEPRECATED:Number = 11;
      
      public static const API_EC_VERSION:Number = 12;
      
      public function FacebookErrorCodes()
      {
         super();
      }
   }
}

