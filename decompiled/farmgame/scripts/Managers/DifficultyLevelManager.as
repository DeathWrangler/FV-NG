package Managers
{
   import Classes.*;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class DifficultyLevelManager implements IFeatureDifficultyLevels
   {
      
      public static const DEFAULT_RECOMM_LEVEL:int = 0;
      
      public static const RECOMM_LEVEL_FEATURE_NAME:String = "EMH";
      
      public static const RECOMM_LEVEL_FEATURE_OPTION:String = "difficultyLevel";
      
      public static const FEATURE_OPTIONS_DIFICULTY_SWITCH_COUNT:String = "difficultySwitchCount";
      
      public static const FEATURE_OPTIONS_DIFICULTY_LEVEL:String = "difficultyLevel";
      
      protected static const PLOT_INDEX:String = "0";
      
      protected static const TEND_INDEX:String = "1";
      
      private static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const NUM_PLOTS_IN_EACH_LEVEL:int = 8;
      
      protected var m_ServiceClassName:String;
      
      protected var m_featureOptionKey:String;
      
      protected var m_featureName:String;
      
      protected var m_recommendedLevel:int;
      
      protected var m_staticData:Object;
      
      protected var m_difficultyLevel:int = -1;
      
      public function DifficultyLevelManager()
      {
         super();
         this.initializeDifficultylevel();
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
         if(featureData)
         {
            this.m_difficultyLevel = featureData[FEATURE_OPTIONS_DIFICULTY_LEVEL];
         }
      }
      
      private function loadStaticData() : void
      {
         var asset:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.collectionItems = new Array();
         this.m_staticData.UIDifficultyDialog = "";
         this.m_staticData.UIConfirmationDialog = "";
         this.m_staticData.endDate = "";
         this.m_staticData.currencyItemName = "";
         this.m_staticData.bonusItemName = "";
         this.m_staticData.SwitchMaxCount = "";
         this.m_staticData.difficultyLevels = "";
         this.m_staticData.bonusItemHidden = "";
         this.m_staticData.windowName = "";
         var featureparentXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureparentXML != null)
         {
            this.m_staticData.endDate = featureparentXML.listEndDate.toString();
            this.m_staticData.windowName = featureparentXML.windowName.toString();
            if(featureparentXML.assets != "")
            {
               for each(asset in featureparentXML.assets.asset)
               {
                  if(asset.@name == "difficultyDialog")
                  {
                     this.m_staticData.UIDifficultyDialog = asset.@path.toString();
                  }
                  else if(asset.@name == "confirmationDialog")
                  {
                     this.m_staticData.UIConfirmationDialog = asset.@path.toString();
                  }
               }
            }
         }
      }
      
      public function get windowName() : String
      {
         return this.m_staticData.windowName;
      }
      
      public function get difficultyLevels() : int
      {
         return this.m_staticData.difficultyLevels;
      }
      
      public function get recommendedDifficultyLevel() : int
      {
         return this.m_recommendedLevel;
      }
      
      public function get confirmationDialog() : String
      {
         return this.m_staticData.UIConfirmationDialog;
      }
      
      public function getCurrentDifficultyLevel() : int
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
         if(featureData)
         {
            this.m_difficultyLevel = featureData[FEATURE_OPTIONS_DIFICULTY_LEVEL];
         }
         return this.m_difficultyLevel;
      }
      
      private function initializeDifficultylevel() : void
      {
         this.initializeRecommendedDifficulty();
      }
      
      public function initializeRecommendedDifficulty() : void
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(RECOMM_LEVEL_FEATURE_NAME,RECOMM_LEVEL_FEATURE_OPTION);
         if(data)
         {
            this.m_recommendedLevel = Number(data);
         }
         else
         {
            this.m_recommendedLevel = DEFAULT_RECOMM_LEVEL;
         }
      }
      
      public function setInitialDifficultyLevel(level:int) : void
      {
         this.m_difficultyLevel = level;
         var featureOptionData:Object = new Object();
         featureOptionData[FEATURE_OPTIONS_DIFICULTY_LEVEL] = level;
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureOptionKey,this.m_featureName,featureOptionData);
         TransactionManager.addTransaction(new TGenericTransaction(this.m_ServiceClassName,"setDifficultyLevel",null,[this.m_featureName,level]));
         FarmStatsManager.count(this.m_featureName,"Difficulty Select",this.m_difficultyLevel.toString(),"First Time",this.recommendedDifficultyLevel.toString(),this.recommendedDifficultyLevel.toString());
      }
      
      public function setDifficultyLevelForReplay(level:int) : void
      {
         var previousDifficultyLevel:int = this.m_difficultyLevel;
         this.m_difficultyLevel = level;
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
         featureOptionData[FEATURE_OPTIONS_DIFICULTY_LEVEL] = level;
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureOptionKey,this.m_featureName,featureOptionData);
         TransactionManager.addTransaction(new TGenericTransaction(this.m_ServiceClassName,"setDifficultyLevelForReplay",null,[this.m_featureName,level]));
         FarmStatsManager.count(this.m_featureName,"Difficulty Select",this.m_difficultyLevel.toString(),"level_complete_" + previousDifficultyLevel.toString(),this.recommendedDifficultyLevel.toString());
      }
      
      private function removeProgress(plotData:Object, i:int) : Object
      {
         if(plotData[i][TEND_INDEX] != 0)
         {
            plotData[i][TEND_INDEX] = 0;
            if(plotData[i][PLOT_INDEX] > 0 && plotData[i][PLOT_INDEX] < 6)
            {
               plotData[i][PLOT_INDEX] = plotData[i][PLOT_INDEX] - 1;
            }
         }
         return plotData;
      }
      
      private function removeProgressAfterSwitch() : Object
      {
         var difficulty:int = this.getCurrentDifficultyLevel();
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
         var plotData:Object = featureOptionData[PLOT_INDEX];
         for(var i:int = 0; i < 3 * NUM_PLOTS_IN_EACH_LEVEL; i++)
         {
            switch(difficulty)
            {
               case 0:
                  if(i >= 0 && i < NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     plotData = this.removeProgress(plotData,i);
                  }
                  break;
               case 1:
                  if(i >= NUM_PLOTS_IN_EACH_LEVEL && i < 2 * NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     plotData = this.removeProgress(plotData,i);
                  }
                  break;
               case 2:
                  if(i >= 2 * NUM_PLOTS_IN_EACH_LEVEL && i < 3 * NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     plotData = this.removeProgress(plotData,i);
                  }
            }
         }
         return plotData;
      }
      
      public function switchDifficultyLevel(level:Number) : void
      {
         var previousDifficultyLevel:int = 0;
         var plotData:Object = null;
         var featureOptionData:Object = null;
         if(this.canSwitchDifficultyLevel())
         {
            previousDifficultyLevel = this.m_difficultyLevel;
            plotData = this.removeProgressAfterSwitch();
            this.m_difficultyLevel = level;
            featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
            featureOptionData[FEATURE_OPTIONS_DIFICULTY_LEVEL] = level;
            featureOptionData[FEATURE_OPTIONS_DIFICULTY_SWITCH_COUNT] = 1;
            featureOptionData[PLOT_INDEX] = plotData;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureOptionKey,this.m_featureName,featureOptionData);
            TransactionManager.addTransaction(new TGenericTransaction(this.m_ServiceClassName,"switchDifficultyLevel",null,[this.m_featureName,level]));
            FarmStatsManager.count(this.m_featureName,"Difficulty Select",this.m_difficultyLevel.toString(),"switch_" + previousDifficultyLevel.toString(),this.recommendedDifficultyLevel.toString());
         }
      }
      
      public function canSwitchDifficultyLevel() : Boolean
      {
         var isPossible:Boolean = true;
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureOptionKey,this.m_featureName);
         if(!featureOptionData.hasOwnProperty(FEATURE_OPTIONS_DIFICULTY_SWITCH_COUNT))
         {
            isPossible = true;
         }
         return isPossible;
      }
      
      public function getEndDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function getAdditionalDaysForRedeem() : int
      {
         return REDEEM_ADDITIONAL_DAYS;
      }
      
      public function openConfirmationWindow(callBack:Function = null, selectedDifficulty:String = null) : void
      {
      }
      
      public function setDifficultyLevel(level:int) : void
      {
      }
   }
}

