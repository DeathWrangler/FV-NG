package Classes.util
{
   public class ParseXMLUtil
   {
      
      private static const TRUE:String = "true";
      
      public function ParseXMLUtil()
      {
         super();
      }
      
      public static function parseRequiredString(xml:XML, token:String) : String
      {
         var result:String = null;
         if(xml.hasOwnProperty(token))
         {
            return xml[token].toString();
         }
         throw new Error("Error: missing required " + token + " tag for xml=" + xml);
      }
      
      public static function parseOptionalString(xml:XML, token:String, defaultValue:String) : String
      {
         var result:String = defaultValue;
         if(xml.hasOwnProperty(token))
         {
            result = xml[token].toString();
         }
         return result;
      }
      
      public static function parseRequiredUInt(xml:XML, token:String) : uint
      {
         var result:uint = 0;
         if(xml.hasOwnProperty(token))
         {
            return uint(uint(xml[token].toString()));
         }
         throw new Error("Error: missing required " + token + " tag for xml=" + xml);
      }
      
      public static function parseOptionalUInt(xml:XML, token:String, defaultValue:uint) : uint
      {
         var result:uint = defaultValue;
         if(xml.hasOwnProperty(token))
         {
            result = uint(xml[token].toString());
         }
         return result;
      }
      
      public static function parseRequiredNumber(xml:XML, token:String) : Number
      {
         var result:Number = 0;
         if(xml.hasOwnProperty(token))
         {
            return Number(Number(xml[token].toString()));
         }
         throw new Error("Error: missing required " + token + " tag for xml=" + xml);
      }
      
      public static function parseOptionalNumber(xml:XML, token:String, defaultValue:Number) : Number
      {
         var result:Number = defaultValue;
         if(xml.hasOwnProperty(token))
         {
            result = Number(xml[token].toString());
         }
         return result;
      }
      
      public static function parseRequiredBoolean(xml:XML, token:String) : Boolean
      {
         var result:Boolean = false;
         if(xml.hasOwnProperty(token))
         {
            return xml[token].toString() == TRUE;
         }
         throw new Error("Error: missing required " + token + " tag for xml=" + xml);
      }
      
      public static function parseOptionalBoolean(xml:XML, token:String, defaultValue:Boolean) : Boolean
      {
         var result:Boolean = defaultValue;
         if(xml.hasOwnProperty(token))
         {
            result = xml[token].toString() == TRUE;
         }
         return result;
      }
   }
}

