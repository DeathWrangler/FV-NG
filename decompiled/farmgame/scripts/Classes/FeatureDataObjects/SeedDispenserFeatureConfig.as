package Classes.FeatureDataObjects
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class SeedDispenserFeatureConfig
   {
      
      private var m_seedPackageSizeKeys:Array;
      
      private var m_seeds:Array;
      
      public function SeedDispenserFeatureConfig(rawXML:XML)
      {
         var seedPackageSizeKeyXML:XML = null;
         var seedXML:XML = null;
         var level:int = 0;
         super();
         this.m_seedPackageSizeKeys = [];
         for each(seedPackageSizeKeyXML in rawXML.seedPackageSizeKey)
         {
            level = parseInt(seedPackageSizeKeyXML.@level.toString());
            this.m_seedPackageSizeKeys[level] = seedPackageSizeKeyXML.@name.toString();
         }
         this.m_seeds = [];
         for each(seedXML in rawXML.seed)
         {
            this.m_seeds.push(new SeedDispenserSeedConfig(seedXML));
         }
      }
      
      public function getSeedPackageSizeKey(level:int) : String
      {
         var result:String = null;
         if(level >= 0 && level <= this.m_seedPackageSizeKeys.length)
         {
            result = this.m_seedPackageSizeKeys[level] as String;
         }
         return result;
      }
      
      public function getSeeds(checkPrereqs:Boolean = true) : Array
      {
         var seedConfig:SeedDispenserSeedConfig = null;
         var result:Array = [];
         for each(seedConfig in this.m_seeds)
         {
            if(!checkPrereqs || !seedConfig.prereqs || PrerequisiteUtility.arePrerequisitesMet(seedConfig.prereqs))
            {
               result.push(seedConfig);
            }
         }
         return result;
      }
   }
}

