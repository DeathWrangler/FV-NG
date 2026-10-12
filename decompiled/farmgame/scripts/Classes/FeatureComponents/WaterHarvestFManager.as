package Classes.FeatureComponents
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.FeatureBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleHarvestableResource;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.IrrigationManager;
   import Widgets.Windows.IrrigationMeterFullWindow;
   import flash.geom.Point;
   
   public class WaterHarvestFManager extends HarvestFManager
   {
      
      private var m_waterHarvestTable:Object;
      
      public function WaterHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getWaterHarvestAmountForLevel(levelNum:int) : int
      {
         var prereqs:Array = null;
         var prereq:Object = null;
         var level:int = 0;
         var water:int = 0;
         var questTechRewardData:BaseDataSource = null;
         var rewardDataArray:Array = null;
         var rewardData:BaseDataSource = null;
         var questTechReward:XML = null;
         var reward:XML = null;
         if(!this.m_waterHarvestTable)
         {
            this.m_waterHarvestTable = {};
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_questTechRewardsDataArray)
               {
                  for each(questTechRewardData in m_questTechRewardsDataArray)
                  {
                     level = -1;
                     water = -1;
                     prereqs = PrerequisiteUtility.parseDataSourcePrereqs(questTechRewardData.getArray("prereqs","prereq"));
                     for each(prereq in prereqs)
                     {
                        if(prereq[PrerequisiteConstants.KEY_TYPE] == PrerequisiteConstants.PREREQUISITE_COMPARE && prereq[PrerequisiteConstants.KEY_CONTEXT_PATH] == "expand.storageLevel")
                        {
                           level = int(prereq[PrerequisiteConstants.KEY_VALUE]);
                           rewardDataArray = questTechRewardData.getArray("reward");
                           if(rewardDataArray.length > 0)
                           {
                              for each(rewardData in rewardDataArray)
                              {
                                 if(rewardData.getString("type") == "irrigation" && rewardData.getString("actionType") == "waterPlots")
                                 {
                                    water = rewardData.getInt("value");
                                    break;
                                 }
                              }
                              if(level != -1 && water != -1)
                              {
                                 this.m_waterHarvestTable[level] = water;
                              }
                           }
                        }
                     }
                  }
               }
            }
            else if(m_questTechRewards)
            {
               this.m_waterHarvestTable = {};
               for each(questTechReward in m_questTechRewards)
               {
                  level = -1;
                  water = -1;
                  prereqs = PrerequisiteUtility.parseXmlNodePrereqs(questTechReward.prereqs.prereq);
                  for each(prereq in prereqs)
                  {
                     if(prereq[PrerequisiteConstants.KEY_TYPE] == PrerequisiteConstants.PREREQUISITE_COMPARE && prereq[PrerequisiteConstants.KEY_CONTEXT_PATH] == "expand.storageLevel")
                     {
                        level = int(prereq[PrerequisiteConstants.KEY_VALUE]);
                        for each(reward in questTechReward.reward)
                        {
                           if(reward.@type == "irrigation" && reward.@actionType == "waterPlots")
                           {
                              water = int(reward.@value.toString());
                              break;
                           }
                        }
                        if(level != -1 && water != -1)
                        {
                           this.m_waterHarvestTable[level] = water;
                        }
                     }
                  }
               }
            }
         }
         return this.m_waterHarvestTable[levelNum];
      }
      
      public function getWaterHarvestAmountForCurrentLevel() : int
      {
         return this.getWaterHarvestAmountForLevel(m_owner.storageLevel);
      }
      
      override public function onPreHarvest() : void
      {
         var point:Point = null;
         var waterGiven:int = this.getWaterHarvestAmountForCurrentLevel();
         if(waterGiven > 0)
         {
            point = m_owner.displayStatusStartPos();
            UI.displayStatus("+" + waterGiven + " Water",point.x,point.y,"",null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,16777215);
         }
         super.onPreHarvest();
      }
      
      override public function getHarvestArrow() : Class
      {
         return SimpleHarvestableResource.BLUE_ARROW;
      }
      
      override public function canAcceptHarvestReward() : Boolean
      {
         var result:Boolean = super.canAcceptHarvestReward();
         var waterOnHarvest:int = this.getWaterHarvestAmountForCurrentLevel();
         if(IrrigationManager.instance.getWaterAmount(IrrigationManager.WATER_PLOTS) + waterOnHarvest > IrrigationManager.instance.getMaxWaterForActionType(IrrigationManager.WATER_PLOTS))
         {
            result = false;
         }
         return result;
      }
      
      override public function displayMessageForUnclaimableHarvestReward() : void
      {
         super.displayMessageForUnclaimableHarvestReward();
         UI.displayPopup(new IrrigationMeterFullWindow(),false);
      }
   }
}

