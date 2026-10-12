package Classes.Collections
{
   import Classes.GameSettingsObject;
   import Classes.breeding.MutableAnimalState;
   
   public class AnimalBreedingCollectible extends GameSettingsObject
   {
      
      public static const PLAIN_PATTERN:String = "a";
      
      private var m_featureName:String;
      
      private var m_owned:int;
      
      private var m_metaHashKey:String;
      
      public function AnimalBreedingCollectible(xml:XML, featureName:String)
      {
         super(xml);
         this.m_owned = 0;
         this.m_featureName = featureName;
      }
      
      public function get tint() : String
      {
         return m_xml.@tint;
      }
      
      public function get pattern() : String
      {
         return m_xml.@pattern;
      }
      
      public function get gene() : String
      {
         return m_xml.@gene;
      }
      
      public function get numneeded() : int
      {
         return m_xml.@numneeded;
      }
      
      public function get request() : Boolean
      {
         return m_xml.hasOwnProperty("@request") && Boolean(m_xml.@request) == true;
      }
      
      public function get dna() : Object
      {
         var result:Object = {};
         result[MutableAnimalState.NAME_DATA_KEY] = "";
         result[MutableAnimalState.GENDER_DATA_KEY] = MutableAnimalState.GENDER_CODE_MALE;
         result[MutableAnimalState.BASE_COLOR_DATA_KEY] = Global.animalBreedingSettings.getColorObj(this.tint);
         var patternColor:Object = Global.animalBreedingSettings.getColorObj(this.pattern);
         var patternCode:String = Global.animalBreedingSettings.getPatternTraitByName(this.m_featureName,this.gene);
         patternCode = patternCode != "" ? patternCode : AnimalBreedingCollectible.PLAIN_PATTERN;
         result[MutableAnimalState.PATTERN_DATA_KEY] = {};
         result[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.TYPE_DATA_KEY] = patternCode;
         result[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.HUE_DATA_KEY] = patternColor[MutableAnimalState.HUE_DATA_KEY];
         result[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.SATURATION_DATA_KEY] = patternColor[MutableAnimalState.SATURATION_DATA_KEY];
         result[MutableAnimalState.PATTERN_DATA_KEY][MutableAnimalState.INTENSITY_DATA_KEY] = patternColor[MutableAnimalState.INTENSITY_DATA_KEY];
         return result;
      }
      
      public function get numOwned() : int
      {
         return this.m_owned;
      }
      
      public function set numOwned(owned:int) : void
      {
         this.m_owned = owned;
      }
      
      public function get metaHash() : String
      {
         return this.m_metaHashKey;
      }
      
      public function set metaHash(metaHash:String) : void
      {
         this.m_metaHashKey = metaHash;
      }
   }
}

