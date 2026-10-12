package Managers
{
   public class LandBundleUnlockFeatureHelper extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "LandBundleUnlockFeatureHelper";
      
      private var m_landBundleWorlds:Object = {
         "ireland":1,
         "borabora":1
      };
      
      public function LandBundleUnlockFeatureHelper(featureName:String)
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String = "LandBundleUnlockFeatureHelper") : LandBundleUnlockFeatureHelper
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,LandBundleUnlockFeatureHelper) as LandBundleUnlockFeatureHelper;
      }
      
      public function worldHasLandBundleFeature(worldName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_landBundleWorlds.hasOwnProperty(worldName))
         {
            result = true;
         }
         return result;
      }
   }
}

