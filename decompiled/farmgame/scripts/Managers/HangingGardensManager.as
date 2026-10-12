package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Managers.HUDTutorialManager;
   import Classes.MapResource;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.HangingGardensFTUECompletionDialog;
   import Display.MOTD;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetMOTD;
   import Widgets.Constants.Market.Currency;
   
   public class HangingGardensManager
   {
      
      private static var s_instance:HangingGardensManager;
      
      public static const FEATURE_NAME:String = "hangingGardens";
      
      public static const HANGING_GARDENS_TRAVEL_FEATURE_FREQUENCY_KEY:String = "hangingGardensTravel";
      
      private static const TROWEL_REWARD_STRING:String = "xhg_trowels_rewardString";
      
      private static const HANGING_GARDENS_ACTION_COUNTER:String = "HangingGardensStageNumber";
      
      public static const HANGING_GARDENS_FTUE_SEEN_FLAG:String = "hangingGardens_ftue_complete";
      
      private static const FOUR_PANEL_HUD_ICON:String = "hangingGardensFTUE";
      
      private static const HANGING_GARDENS_MINIMUM_LEVEL:int = 15;
      
      private static const HANGING_GARDENS_VISIT_WORLD_SEEN_FLAG:String = "hangingGardenVisitedWorld";
      
      public static const HANGING_GARDENS:String = "garden";
      
      private static const SEEN_MOTD_THIS_SESSION:String = "hangingGardensSeenMOTDThisSession";
      
      private static var s_experimentVariant:int = -1;
      
      private var m_stage:int;
      
      private var m_hangingGardenStages:Object = {};
      
      private var m_fourPanelImages:Array;
      
      public function HangingGardensManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[HangingGardensManager] :: Use GetInstance()");
         this.init();
      }
      
      public static function get instance() : HangingGardensManager
      {
         if(!s_instance)
         {
            s_instance = new HangingGardensManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function isInHangingGardensExperiment() : Boolean
      {
         if(s_experimentVariant == -1)
         {
            s_experimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_GARDEN);
         }
         return s_experimentVariant == 1;
      }
      
      private function init() : void
      {
         var i:int = 0;
         var stageData:XML = null;
         var image:XML = null;
         this.m_stage = Global.player.getActionCount(HANGING_GARDENS_ACTION_COUNTER);
         this.m_fourPanelImages = new Array();
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         var stages:XMLList = null;
         if(feature.stageTreasurePrices)
         {
            stages = feature.stageTreasurePrices.stage;
         }
         if(stages)
         {
            for(i = 0; i < stages.length(); i++)
            {
               stageData = stages[i];
               this.m_hangingGardenStages[stageData.@number] = {
                  "price":stageData.@price,
                  "prereq":stageData.@prereq
               };
            }
         }
         var images:XMLList = null;
         if(feature.images)
         {
            images = feature.images.image;
         }
         if(images)
         {
            for each(image in images)
            {
               this.m_fourPanelImages.push(image.@path);
            }
         }
      }
      
      public function determineStageNumber() : void
      {
         var stage:Object = null;
         var count:int = 0;
         for each(stage in this.m_hangingGardenStages)
         {
            if(stage.hasOwnProperty("prereq"))
            {
               if(PrerequisiteUtility.checkPrereqByName(stage.prereq))
               {
                  this.m_stage = count;
               }
            }
            count++;
         }
         Global.player.setActionCount(HANGING_GARDENS_ACTION_COUNTER,this.m_stage);
      }
      
      private function surfaceHangingGardensOnRecieveTrowels() : void
      {
      }
      
      public function showHangingGardensMOTD() : void
      {
         TransactionManager.addTransaction(new TGetMOTD("MOTD_HANGING_GARDENS_2013",this.showMOTDCallback),true);
      }
      
      private function showMOTDCallback(result:Object) : void
      {
         var motdData:Object = null;
         if(Boolean(result) && result.hasOwnProperty("motdSeenFlag"))
         {
            motdData = result;
            MOTD.displayMOTD(motdData,false);
         }
      }
      
      public function shouldShowTrowelToaster() : Boolean
      {
         var lastTimeFeatureWasShown:Number = NaN;
         var result:Boolean = false;
         if(HangingGardensManager.isInHangingGardensExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_GARDEN_TOASTER) > 0)
         {
            lastTimeFeatureWasShown = Global.player.getFeatureLastShown(HANGING_GARDENS_TRAVEL_FEATURE_FREQUENCY_KEY);
            if(!Global.player.canShowFeatureWithFeatureFrequency(HANGING_GARDENS_TRAVEL_FEATURE_FREQUENCY_KEY,7) && Global.player.canShowFeatureWithFeatureFrequency(FEATURE_NAME,1))
            {
               result = true;
            }
            else if(Global.player.canShowFeatureWithFeatureFrequency(FEATURE_NAME,3))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function awardTrowels(resource:MapResource, numberOfTrowels:Number) : void
      {
         if(HangingGardensManager.isInHangingGardensExperiment())
         {
            Global.player.updateWorldCurrency(QuestConstants.REWARD_TROWELS,numberOfTrowels);
            resource.displayStatus(ZLocUtils.t("Dialogs",TROWEL_REWARD_STRING,{"numberOfTrowels":numberOfTrowels}),Global.getAssetURL(Currency.getIcon(Currency.TROWELS)));
            this.surfaceHangingGardensOnRecieveTrowels();
         }
      }
      
      public function addFourPanelHudIcon() : void
      {
         if(Global.hud.iconQueue.getIconByName(FOUR_PANEL_HUD_ICON) == null)
         {
            Global.hud.iconQueue.addIconToTop(FOUR_PANEL_HUD_ICON);
         }
      }
      
      public function removeFourPanelHudIcon() : void
      {
         Global.hud.iconQueue.removeIconByName(FOUR_PANEL_HUD_ICON);
      }
      
      public function displayFourPanelDialog() : void
      {
         var i:int = 0;
         var items:Array = new Array();
         if(this.m_fourPanelImages)
         {
            for(i = 0; i < this.m_fourPanelImages.length; i++)
            {
               items.push({
                  "overview":FEATURE_NAME + "_Slot" + i + "Overview",
                  "title":FEATURE_NAME + "_Slot" + i + "Title",
                  "body":FEATURE_NAME + "_Slot" + i + "Body",
                  "imageUrl":this.m_fourPanelImages[i],
                  "buttonTitle":"",
                  "buttonUrl":"",
                  "localiztionBundle":"Dialogs"
               });
            }
            TutorialUI.displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs",FEATURE_NAME + "_Title"),false,false);
         }
      }
      
      public function beginFTUE() : void
      {
         HUDTutorialManager.instance.initialize(HangingGardensManager.FEATURE_NAME,this.showPostTutorialDialog);
      }
      
      public function showPostTutorialDialog() : void
      {
         UI.displayPopup(new HangingGardensFTUECompletionDialog());
         Global.player.setSeenFlag(HangingGardensManager.HANGING_GARDENS_FTUE_SEEN_FLAG);
         HangingGardensManager.instance.addFourPanelHudIcon();
         FarmStatsManager.featureSample("Hanging_Gardens","FTUE","end");
         HUDTutorialManager.instance.initialize("hangingGardensStatic");
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
