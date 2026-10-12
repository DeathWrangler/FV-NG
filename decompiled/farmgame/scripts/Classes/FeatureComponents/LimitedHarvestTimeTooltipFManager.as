package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class LimitedHarvestTimeTooltipFManager extends FeatureManager implements ITooltipComponent
   {
      
      private var m_limitedHarvestTime:Number = -1;
      
      private var m_originalPlantTime:Number = -1;
      
      public function LimitedHarvestTimeTooltipFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getTooltip() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var timeLeftText:String = null;
         var result:String = "";
         if(this.limitedHarvestTime > 0 && this.originalPlantTime > 0)
         {
            endTime = this.originalPlantTime + this.limitedHarvestTime;
            timeLeft = endTime - GlobalEngine.serverTime / 1000;
            if(timeLeft > 0)
            {
               timeLeftText = FarmGameUtil.toFriendlyTime(timeLeft,true);
               result = ZLocUtils.t("Dialogs",owner.getItemName() + "Tooltip",{"timeLeft":timeLeftText});
            }
         }
         return result;
      }
      
      private function get limitedHarvestTime() : Number
      {
         var featureData:BaseDataSource = null;
         var featureXML:XML = null;
         if(this.m_limitedHarvestTime < 0)
         {
            if(owner)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  featureData = owner.getItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME);
                  if(featureData)
                  {
                     this.m_limitedHarvestTime = featureData.getNumber("limitedHarvestTime");
                  }
               }
               else
               {
                  featureXML = owner.getItem().getFeatureXMLByName(FeatureManager.HARVEST_FEATURE_NAME);
                  if(featureXML)
                  {
                     this.m_limitedHarvestTime = parseFloat(featureXML.limitedHarvestTime.toString());
                  }
               }
            }
         }
         return this.m_limitedHarvestTime;
      }
      
      private function get originalPlantTime() : Number
      {
         var originalPlantTime:Number = NaN;
         if(this.m_originalPlantTime < 0)
         {
            if(Boolean(owner) && Boolean(owner.extraDataState))
            {
               originalPlantTime = owner.extraDataState.getProperty("originalPlantTime") as Number;
               this.m_originalPlantTime = originalPlantTime > 0 ? originalPlantTime : 0;
            }
         }
         return this.m_originalPlantTime;
      }
   }
}

