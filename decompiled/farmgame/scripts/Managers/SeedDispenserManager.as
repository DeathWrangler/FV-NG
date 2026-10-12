package Managers
{
   import Classes.FeatureDataObjects.SeedDispenserFeatureConfig;
   import Classes.FeatureDataObjects.SeedDispenserSeedConfig;
   import Classes.Mastery;
   import Classes.ZItem.SeedItem;
   
   public class SeedDispenserManager
   {
      
      private static var m_featureConfigs:Object = {};
      
      public function SeedDispenserManager()
      {
         super();
      }
      
      public static function getFeatureConfig(featureName:String) : SeedDispenserFeatureConfig
      {
         var result:SeedDispenserFeatureConfig = null;
         var featureXML:XML = null;
         if(featureName)
         {
            if(m_featureConfigs[featureName])
            {
               result = m_featureConfigs[featureName] as SeedDispenserFeatureConfig;
            }
            else
            {
               featureXML = Global.farmGameSettingsManager.getFeatureXML(featureName);
               if(featureXML)
               {
                  result = new SeedDispenserFeatureConfig(featureXML);
                  m_featureConfigs[featureName] = result;
               }
            }
         }
         return result;
      }
      
      public static function getSeedPackageSize(featureName:String, buildingLevel:int) : int
      {
         var result:int = 0;
         var seedPackageSizeKey:String = null;
         var featureConfig:SeedDispenserFeatureConfig = getFeatureConfig(featureName);
         if(featureConfig)
         {
            seedPackageSizeKey = featureConfig.getSeedPackageSizeKey(buildingLevel);
            result = Global.farmGameSettingsManager.getInt(seedPackageSizeKey,Global.farmGameSettingsManager.getDefaultSeedPackageSize());
         }
         return result;
      }
      
      public static function getSeeds(featureName:String, checkPrereqs:Boolean = true) : Array
      {
         var result:Array = null;
         var featureConfig:SeedDispenserFeatureConfig = getFeatureConfig(featureName);
         if(featureConfig)
         {
            result = featureConfig.getSeeds(checkPrereqs);
         }
         return result;
      }
      
      public static function getActiveSeed(featureName:String) : SeedDispenserSeedConfig
      {
         var result:SeedDispenserSeedConfig = null;
         var seedConfig:SeedDispenserSeedConfig = null;
         var seedItem:SeedItem = null;
         var mastery:Mastery = null;
         var seeds:Array = getSeeds(featureName);
         if(seeds)
         {
            for each(seedConfig in seeds)
            {
               seedItem = Global.farmGameSettingsManager.getFarmItemByName(seedConfig.name) as SeedItem;
               if(seedItem)
               {
                  mastery = seedItem.mastery;
                  if(Boolean(mastery) && !mastery.hasAllMasteries())
                  {
                     result = seedConfig;
                     break;
                  }
               }
            }
         }
         if(!result)
         {
            result = seedConfig;
         }
         return result;
      }
      
      public static function getPreviousSeed(featureName:String, seedName:String) : SeedDispenserSeedConfig
      {
         var result:SeedDispenserSeedConfig = null;
         var seedIndex:int = 0;
         var seed:SeedDispenserSeedConfig = null;
         var previousStageIndex:int = 0;
         var seeds:Array = getSeeds(featureName);
         if(seeds)
         {
            for(seedIndex = 0; seedIndex < seeds.length; seedIndex++)
            {
               seed = seeds[seedIndex] as SeedDispenserSeedConfig;
               if(seed.name == seedName)
               {
                  previousStageIndex = seedIndex - 1;
                  if(previousStageIndex >= 0)
                  {
                     result = seeds[previousStageIndex];
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getNextSeed(featureName:String, seedName:String) : SeedDispenserSeedConfig
      {
         var result:SeedDispenserSeedConfig = null;
         var seedIndex:int = 0;
         var seed:SeedDispenserSeedConfig = null;
         var nextStageIndex:int = 0;
         var seeds:Array = getSeeds(featureName);
         if(seeds)
         {
            for(seedIndex = 0; seedIndex < seeds.length; seedIndex++)
            {
               seed = seeds[seedIndex] as SeedDispenserSeedConfig;
               if(seed.name == seedName)
               {
                  nextStageIndex = seedIndex + 1;
                  if(seeds.length > nextStageIndex)
                  {
                     result = seeds[nextStageIndex];
                  }
                  break;
               }
            }
         }
         return result;
      }
   }
}

