package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.BeanstalkHoverManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BeanstalkRewardsWindow;
   import Widgets.Windows.BeanstalkToasterWindow;
   import flash.events.MouseEvent;
   
   public class EverGrowingHarvestableBuilding extends HarvestableStorageBuilding
   {
      
      private var m_totalHeight:int = 0;
      
      private var m_maxHeight:int = 0;
      
      private var m_configuration:FeatureConfigManager = null;
      
      private var m_hoverManager:BeanstalkHoverManager = null;
      
      private var m_currentGoalHeightPreHarvest:int = 0;
      
      private var m_currentGoalHeightPostHarvest:int = 0;
      
      private var m_hadWithered:Boolean = false;
      
      private var m_witherRestoreHeight:int = 0;
      
      public var growthStep:int = 0;
      
      public function EverGrowingHarvestableBuilding(itemName:String = null)
      {
         super(itemName);
         this.m_configuration = FeatureConfigManager.getFeatureConfiguration(itemName);
         this.growthStep = this.m_configuration.getNumberConstant("growStep");
         this.m_hoverManager = new BeanstalkHoverManager(this);
      }
      
      override public function loadObject(data:Object) : void
      {
         var witherDelta:String = null;
         var toaster:BeanstalkToasterWindow = null;
         super.loadObject(data);
         if(data.hasOwnProperty("height"))
         {
            this.m_totalHeight = data.height;
         }
         if(data.hasOwnProperty("maxHeight"))
         {
            this.m_maxHeight = data.maxHeight;
         }
         if(data.hasOwnProperty("m_witherRestoreHeight"))
         {
            this.m_witherRestoreHeight = data["m_witherRestoreHeight"];
         }
         if(data.hasOwnProperty("hadWithered") && data.hadWithered == true)
         {
            witherDelta = (this.m_witherRestoreHeight - this.m_totalHeight).toString();
            FarmStatsManager.featureSample("magic_beanstalk","mainflow","wither",witherDelta);
            toaster = new BeanstalkToasterWindow(this.m_hoverManager);
            this.m_hadWithered = true;
            ToasterManager.getInstance().add(toaster);
         }
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         if(!Global.player.getSeenFlag("BeanstalkPlaceTutorial"))
         {
            Global.player.setSeenFlag("BeanstalkPlaceTutorial");
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","Retention_Beanstalk_WhatIsThis")));
         }
      }
      
      public function showRewardsDialog(result:Object) : void
      {
         if(result != null && result.hasOwnProperty("featureName") && result.hasOwnProperty("level") && result.hasOwnProperty("height"))
         {
            if(result.hasOwnProperty("newLevelUp"))
            {
               UI.displayPopup(new BeanstalkRewardsWindow(result["featureName"],result["level"]));
            }
            FarmStatsManager.count("magic_beanstalk","mainflow","level_up",result["level"],result["height"]);
         }
      }
      
      public function get maxHeight() : int
      {
         return this.m_maxHeight;
      }
      
      public function get totalHeight() : int
      {
         return this.m_totalHeight;
      }
      
      public function get hadWithered() : Boolean
      {
         return this.m_hadWithered;
      }
      
      public function get witherRestoreHeight() : int
      {
         return this.m_witherRestoreHeight;
      }
      
      public function set totalHeight(value:int) : void
      {
         this.m_totalHeight = value;
      }
      
      public function set hadWithered(value:Boolean) : void
      {
         this.m_hadWithered = value;
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.m_hoverManager.showHovers();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.m_hoverManager.hideHovers();
      }
      
      override public function isHarvestable() : Boolean
      {
         return getGrowPercentage() == 100 || state == STATE_RIPE;
      }
      
      override public function getCurrentSuffix() : int
      {
         return this.getGoalLevelFromHeight(this.m_totalHeight);
      }
      
      override public function setState(value:String) : void
      {
         if(value == STATE_BUILT)
         {
            value = STATE_BARE;
         }
         super.setState(value);
      }
      
      override protected function determineState(delta:Number) : void
      {
         var visit:Boolean = Global.worldManager.isVisiting();
         if(!visit && this.isHarvestable() && state == STATE_BARE)
         {
            this.setState(STATE_RIPE);
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         if(this.m_currentGoalHeightPreHarvest != this.m_currentGoalHeightPostHarvest)
         {
            TransactionManager.addTransaction(new TGenericTransaction("EverGrowingUtilityService","awardEverGrowingLevelRewards",this.showRewardsDialog,["ever_growing_beanstalk"]));
         }
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var growStep:int = this.m_configuration.getNumberConstant("growStep");
         var result:Object = super.doHarvestDropOff(avatar,showStatus);
         harvestYieldsGroup.applyHarvestYieldsForItem(m_item as HarvestableItem,1,1,this as EverGrowingHarvestableBuilding);
         this.m_currentGoalHeightPreHarvest = this.getCurrentGoalHeight();
         this.m_totalHeight += growStep;
         if(this.m_maxHeight < this.m_totalHeight)
         {
            this.m_maxHeight = this.m_totalHeight;
         }
         this.m_currentGoalHeightPostHarvest = this.getCurrentGoalHeight();
         FarmStatsManager.count("magic_beanstalk","mainflow","harvest",growStep.toString());
         if(this.m_hadWithered)
         {
            this.m_hadWithered = false;
         }
         reloadImage();
         return result;
      }
      
      private function getGoalLevelFromHeight(height:int) : int
      {
         var goalLevelsConst:String = this.m_configuration.getStringConstant("goalLevels");
         var goalLevels:Array = goalLevelsConst.split(",");
         var currentLevel:int = 0;
         for(var idx:* = int(goalLevels.length - 1); idx >= 0; idx--)
         {
            if(height >= goalLevels[idx])
            {
               currentLevel = idx;
               break;
            }
         }
         return currentLevel;
      }
      
      public function getCurrentGoalLevel() : int
      {
         return this.getGoalLevelFromHeight(this.m_totalHeight);
      }
      
      public function getCurrentGoalHeight() : int
      {
         var goalLevelsConst:String = this.m_configuration.getStringConstant("goalLevels");
         var goalLevels:Array = goalLevelsConst.split(",");
         return goalLevels[this.getGoalLevelFromHeight(this.m_totalHeight)];
      }
      
      public function getNextGoalHeight() : int
      {
         var goalLevelsConst:String = this.m_configuration.getStringConstant("goalLevels");
         var goalLevels:Array = goalLevelsConst.split(",");
         var nextGoalIdx:int = 0;
         var nextGoal:int = 0;
         for(var idx:* = int(goalLevels.length - 1); idx >= 0; idx--)
         {
            if(this.m_totalHeight >= goalLevels[idx])
            {
               nextGoalIdx = idx + 1;
               break;
            }
         }
         if(nextGoalIdx <= goalLevels.length - 1)
         {
            return int(goalLevels[nextGoalIdx]);
         }
         return -1;
      }
      
      public function getCurrencyMultiplier(currencyType:String) : int
      {
         var multiplier:int = 0;
         var multipliers:Array = null;
         var multipierConst:String = this.m_configuration.getStringConstant("multiplier_" + currencyType);
         if(multipierConst != null)
         {
            multipliers = multipierConst.split(",");
            multiplier = int(multipliers[this.getCurrentGoalLevel()]);
         }
         else
         {
            multiplier = 1;
         }
         return multiplier;
      }
   }
}

