package Classes.breeding
{
   import Classes.AnimalBreedingConfigSettings;
   import com.adobe.crypto.MD5;
   import com.adobe.serialization.json.JSON;
   
   public class MutableAnimalState
   {
      
      public static const HUE_RANGE:Number = 240;
      
      public static const HUE_MAX_VARIANCE:Number = 15;
      
      public static const SATURATION_RANGE:Number = 16;
      
      public static const SATURATION_MAX_VARIANCE:Number = 1;
      
      public static const INTENSITY_RANGE:Number = 16;
      
      public static const INTENSITY_MAX_VARIANCE:Number = 1;
      
      public static const NAME_DATA_KEY:String = "N";
      
      public static const BREEDER_DATA_KEY:String = "U";
      
      public static const GENDER_DATA_KEY:String = "G";
      
      public static const GENDER_CODE_FEMALE:String = "F";
      
      public static const GENDER_CODE_MALE:String = "M";
      
      public static const BASE_COLOR_DATA_KEY:String = "B";
      
      public static const PATTERN_DATA_KEY:String = "P";
      
      public static const HUE_DATA_KEY:String = "H";
      
      public static const SATURATION_DATA_KEY:String = "S";
      
      public static const INTENSITY_DATA_KEY:String = "V";
      
      public static const TYPE_DATA_KEY:String = "T";
      
      private static const HASH_KEY_CHAR_LENGTH:Number = 8;
      
      private static const DEFAULT_JSON_STRING:String = "{\"N\":\"Animal\",\"G\":\"M\",\"B\":{\"H\":[\"c\",\"a1\"],\"S\":[\"0\",\"0\"],\"V\":[\"f\",\"f\"]},\"P\":{\"T\":[\"a\"],\"H\":[\"c6\",\"b7\"],\"S\":[\"0\",\"0\"],\"V\":[\"f\",\"f\"]}}";
      
      private var m_dna:Object = {};
      
      private var m_hash:String = "";
      
      private var m_jsonString:String = "";
      
      public function MutableAnimalState(hash:String, dna:Object, jsonString:String)
      {
         super();
         this.m_hash = hash;
         this.m_dna = dna;
         if(this.m_dna == null)
         {
            this.m_dna = {};
         }
         this.m_jsonString = jsonString;
      }
      
      public static function createFromPhpString(hash:String, jsonString:String) : MutableAnimalState
      {
         if("" == jsonString || null == jsonString)
         {
            jsonString = DEFAULT_JSON_STRING;
         }
         var metadata:Object = com.adobe.serialization.json.JSON.decode(jsonString);
         return new MutableAnimalState(hash,metadata,jsonString);
      }
      
      public function get hash() : String
      {
         return this.m_hash;
      }
      
      public function get jsonString() : String
      {
         return this.m_jsonString;
      }
      
      public function get dna() : Object
      {
         return this.m_dna;
      }
      
      private function diluteHue(dominant:Number, recessive:Number, range:Number) : Number
      {
         var result:Number = (dominant + recessive) % range / 2;
         return (dominant + result) % range / 2;
      }
      
      public function hue(pattern:Boolean = false) : Number
      {
         return this.getColorValue(HUE_DATA_KEY,pattern);
      }
      
      public function saturation(pattern:Boolean = false) : Number
      {
         return this.getColorValue(SATURATION_DATA_KEY,pattern);
      }
      
      public function intensity(pattern:Boolean = false) : Number
      {
         return this.getColorValue(INTENSITY_DATA_KEY,pattern);
      }
      
      private function getColorValue(colorKey:String, pattern:Boolean = false) : Number
      {
         var trait:String = pattern ? PATTERN_DATA_KEY : BASE_COLOR_DATA_KEY;
         var expressedValue:Number = 0;
         if(this.m_dna != null && this.m_dna.hasOwnProperty(trait) && Boolean(this.m_dna[trait].hasOwnProperty(colorKey)))
         {
            trait = this.m_dna.hasOwnProperty(trait) ? trait : BASE_COLOR_DATA_KEY;
            expressedValue = parseInt(this.m_dna[trait][colorKey][0],AnimalBreedingConfigSettings.DEFAULT_HEX_RADIX);
         }
         return expressedValue;
      }
      
      public function get pattern() : String
      {
         var result:String = "";
         if(Boolean(this.m_dna) && this.m_dna.hasOwnProperty(PATTERN_DATA_KEY))
         {
            result = this.m_dna[PATTERN_DATA_KEY][TYPE_DATA_KEY];
         }
         return result;
      }
      
      public function get name() : String
      {
         var name:String = "";
         if(this.m_dna.hasOwnProperty(NAME_DATA_KEY))
         {
            name = this.m_dna[NAME_DATA_KEY];
         }
         return name;
      }
      
      public function get gender() : String
      {
         var gender:String = "";
         if(this.m_dna.hasOwnProperty(GENDER_DATA_KEY))
         {
            gender = this.m_dna[GENDER_DATA_KEY];
         }
         return gender;
      }
      
      public function isMale() : Boolean
      {
         var result:Boolean = false;
         if(this.gender == GENDER_CODE_MALE)
         {
            result = true;
         }
         return result;
      }
      
      public function get statsHSV() : String
      {
         var stats:String = "";
         if(this.m_dna.hasOwnProperty(BASE_COLOR_DATA_KEY))
         {
            if(this.m_dna[BASE_COLOR_DATA_KEY].hasOwnProperty(HUE_DATA_KEY))
            {
               stats += "B:";
               stats += this.hue() + "_";
               stats += this.saturation() + "_";
               stats += this.intensity() + ":";
            }
         }
         if(this.m_dna.hasOwnProperty(PATTERN_DATA_KEY))
         {
            if(this.m_dna[PATTERN_DATA_KEY].hasOwnProperty(HUE_DATA_KEY))
            {
               stats += "P:";
               stats += this.hue(true) + "_";
               stats += this.saturation(true) + "_";
               stats += this.intensity(true);
            }
         }
         return stats;
      }
      
      public function get fromFriend() : Boolean
      {
         var fromFriend:Boolean = false;
         if(this.m_dna.hasOwnProperty(BREEDER_DATA_KEY))
         {
            if(this.m_dna[BREEDER_DATA_KEY] != "" && this.m_dna[BREEDER_DATA_KEY] != String(Global.player.uid))
            {
               fromFriend = true;
            }
         }
         return fromFriend;
      }
      
      public function get breederUid() : String
      {
         var result:String = "";
         if(this.m_dna.hasOwnProperty(BREEDER_DATA_KEY))
         {
            if(this.m_dna[BREEDER_DATA_KEY] != "" && this.m_dna[BREEDER_DATA_KEY] != String(Global.player.uid))
            {
               result = String(this.m_dna[BREEDER_DATA_KEY]);
            }
         }
         return result;
      }
      
      public function set name(value:String) : void
      {
         this.m_dna[NAME_DATA_KEY] = value;
      }
      
      public function getPackedMutableState() : String
      {
         return com.adobe.serialization.json.JSON.encode(this.m_dna);
      }
      
      public function getStateKey() : String
      {
         var result:String = "";
         if(this.m_dna[GENDER_DATA_KEY])
         {
            result += this.m_dna[GENDER_DATA_KEY];
         }
         if(this.m_dna[BASE_COLOR_DATA_KEY])
         {
            result += this.m_dna[BASE_COLOR_DATA_KEY][HUE_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[BASE_COLOR_DATA_KEY][HUE_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
            result += this.m_dna[BASE_COLOR_DATA_KEY][SATURATION_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[BASE_COLOR_DATA_KEY][SATURATION_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
            result += this.m_dna[BASE_COLOR_DATA_KEY][INTENSITY_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[BASE_COLOR_DATA_KEY][INTENSITY_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
         }
         if(this.m_dna[PATTERN_DATA_KEY])
         {
            result += this.m_dna[PATTERN_DATA_KEY][HUE_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[PATTERN_DATA_KEY][HUE_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
            result += this.m_dna[PATTERN_DATA_KEY][SATURATION_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[PATTERN_DATA_KEY][SATURATION_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
            result += this.m_dna[PATTERN_DATA_KEY][INTENSITY_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
            result += ",";
            result += this.m_dna[PATTERN_DATA_KEY][INTENSITY_DATA_KEY][AnimalBreedingConfigSettings.HSV_PARENT_INDEX];
            result += this.m_dna[PATTERN_DATA_KEY][TYPE_DATA_KEY][AnimalBreedingConfigSettings.HSV_CHILD_INDEX];
         }
         return result;
      }
      
      public function getHashKey() : String
      {
         return MD5.hash(this.getStateKey()).slice(0,HASH_KEY_CHAR_LENGTH);
      }
      
      public function isValid() : Boolean
      {
         var result:Boolean = false;
         if(this.m_dna.hasOwnProperty(NAME_DATA_KEY) && this.m_dna.hasOwnProperty(BASE_COLOR_DATA_KEY) && this.m_dna.hasOwnProperty(GENDER_DATA_KEY) && this.m_dna.hasOwnProperty(PATTERN_DATA_KEY) && Boolean(this.m_dna[PATTERN_DATA_KEY].hasOwnProperty(TYPE_DATA_KEY)))
         {
            result = this.isColorDataValid(this.m_dna[BASE_COLOR_DATA_KEY]) && this.isColorDataValid(this.m_dna[PATTERN_DATA_KEY]);
         }
         return result;
      }
      
      private function isColorDataValid(colorData:Object) : Boolean
      {
         var result:Boolean = false;
         if(colorData.hasOwnProperty(HUE_DATA_KEY) && (colorData[HUE_DATA_KEY] as Array).length >= 1 && colorData.hasOwnProperty(SATURATION_DATA_KEY) && (colorData[SATURATION_DATA_KEY] as Array).length >= 1 && colorData.hasOwnProperty(INTENSITY_DATA_KEY) && (colorData[INTENSITY_DATA_KEY] as Array).length >= 1)
         {
            result = true;
         }
         return result;
      }
   }
}

