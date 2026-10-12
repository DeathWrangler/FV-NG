package Classes.DragonBreeding
{
   import Managers.DragonBreedingConfigManager;
   import com.adobe.serialization.json.JSON;
   
   public class MutableDragonState
   {
      
      private static const DEFAULT_JSON_STRING:String = "{\"N\":\"Animal\",\"G\":\"M\",\"B\":{\"H\":[\"c\",\"a1\"],\"S\":[\"0\",\"0\"],\"V\":[\"f\",\"f\"]},\"P\":{\"T\":[\"a\"],\"H\":[\"c6\",\"b7\"],\"S\":[\"0\",\"0\"],\"V\":[\"f\",\"f\"]}}";
      
      private var m_dna:Object = {};
      
      private var m_hash:String = "";
      
      private var m_jsonString:String = "";
      
      public function MutableDragonState(hash:String, dna:Object, jsonString:String)
      {
         super();
         this.m_hash = hash;
         this.m_dna = dna;
         this.m_jsonString = jsonString;
      }
      
      public static function createFromPhpString(hash:String, jsonString:String) : MutableDragonState
      {
         if("" == jsonString || null == jsonString)
         {
            jsonString = DEFAULT_JSON_STRING;
         }
         var metadata:Object = com.adobe.serialization.json.JSON.decode(jsonString);
         return new MutableDragonState(hash,metadata,jsonString);
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
      
      public function get pattern() : String
      {
         var result:String = "";
         if(Boolean(this.m_dna) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.PATTERN_DATA_KEY))
         {
            result = this.m_dna[DragonBreedingConfigManager.PATTERN_DATA_KEY][DragonBreedingConfigManager.TYPE_DATA_KEY];
         }
         return result;
      }
      
      public function get gender() : String
      {
         var gender:String = "";
         if(this.m_dna.hasOwnProperty(DragonBreedingConfigManager.BODY_DATA_KEY))
         {
            gender = this.m_dna[DragonBreedingConfigManager.BODY_DATA_KEY];
         }
         return gender;
      }
      
      public function isMale() : Boolean
      {
         var result:Boolean = false;
         if(this.gender == DragonBreedingConfigManager.GENDER_CODE_MALE)
         {
            result = true;
         }
         return result;
      }
      
      public function getPackedMutableState() : String
      {
         return com.adobe.serialization.json.JSON.encode(this.m_dna);
      }
      
      public function isValid() : Boolean
      {
         var result:Boolean = false;
         if(this.m_dna.hasOwnProperty(DragonBreedingConfigManager.BODY_DATA_KEY) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.FIRE_DATA_KEY) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.HEAD_DATA_KEY) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.PATTERN_DATA_KEY) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.WING_DATA_KEY) && this.m_dna.hasOwnProperty(DragonBreedingConfigManager.NECK_DATA_KEY))
         {
            result = true;
         }
         return result;
      }
   }
}

