package Display
{
   import Classes.FeatureComponents.ExpandFManager;
   import Classes.RuntimeDrivenLootableFixedFeatureBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Events.DynamicObjectEvent;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class RuntimeDrivenCharityWindow extends FarmWindow
   {
      
      private static var s_showFinalRewardOverlay:Boolean = false;
      
      private var m_dialogConfig:Object = null;
      
      private var m_building:RuntimeDrivenLootableFixedFeatureBuilding;
      
      private var m_featureName:String;
      
      private const SAVANNAH_CHARITY_BUILDING_NAME:String = "xaf_savannahconservationcenter";
      
      public function RuntimeDrivenCharityWindow(building:RuntimeDrivenLootableFixedFeatureBuilding)
      {
         this.m_building = building;
         this.m_featureName = building.featureName;
         this.m_dialogConfig = this.m_building.getItem().getDialogConfig("storage");
         super(this.getDialogAssetPath());
      }
      
      public static function setFinalRewardOverlayFlag(useFinalRewardOverlay:Boolean) : void
      {
         s_showFinalRewardOverlay = useFinalRewardOverlay;
      }
      
      override protected function postLoadComplete() : void
      {
         var maxExpansionLevel:int = 0;
         var unitExperimentName:String = null;
         var experimentVariant:int = 0;
         var totalText:String = null;
         var offboardingProgressMeter:MovieClip = null;
         var progressMeter:MovieClip = null;
         super.postLoadComplete();
         var expansionLevel:int = this.m_building.getExpansionLevelFromRuntime();
         var buildingExpandManager:ExpandFManager = new ExpandFManager(this.m_building);
         if(buildingExpandManager)
         {
            maxExpansionLevel = buildingExpandManager.maxExpansionLevel();
         }
         var progressPercent:int = expansionLevel / maxExpansionLevel * 100;
         var runtimeKey:String = this.m_building.getItemName().toUpperCase() + "_PERCENT_OVERRIDE";
         if(Global.flashHotParams.hasOwnProperty(runtimeKey))
         {
            progressPercent = int(Global.flashHotParams[runtimeKey]);
         }
         var buildingConfig:XML = RuntimeDrivenLootableFixedFeatureBuilding.getRuntimeBuildingConfig(this.m_featureName);
         if(buildingConfig)
         {
            unitExperimentName = buildingConfig.@unitExperiment;
            if(unitExperimentName)
            {
               experimentVariant = Global.experimentManager.getExperimentVariant(unitExperimentName);
               totalText = buildingConfig["@unit" + experimentVariant];
            }
         }
         if(m_window.more_bt)
         {
            addWidget(new FarmAnimatedButton(m_window.more_bt,this.onLegalClick));
         }
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "Title")));
         }
         if((Boolean(s_showFinalRewardOverlay) || Boolean(maxExpansionLevel && expansionLevel === maxExpansionLevel)) && Boolean(m_window.offboarding_mc))
         {
            addWidget(new ZwBaseWidget(m_window.offboarding_mc));
            if(m_window.offboarding_mc.learnMore_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.offboarding_mc.learnMore_bt,ZLocUtils.t("Dialogs","FeatureBuildingLearnMore"),this.onLegalClick));
            }
            if(Boolean(m_window.offboarding_mc.header_tf) && Boolean(totalText))
            {
               addWidget(new ZwTextField(m_window.offboarding_mc.header_tf,ZLocUtils.t("Dialogs",this.m_featureName + "GoalThanks")));
            }
            if(Boolean(m_window.offboarding_mc.subheader_tf) && Boolean(totalText))
            {
               addWidget(new ZwTextField(m_window.offboarding_mc.subheader_tf,ZLocUtils.t("Dialogs",this.m_featureName + "Finish")));
            }
            if(m_window.offboarding_mc.meter_mc)
            {
               offboardingProgressMeter = m_window.offboarding_mc.meter_mc;
               addWidget(new ZwBaseWidget(offboardingProgressMeter));
               offboardingProgressMeter.gotoAndStop(progressPercent);
               if(offboardingProgressMeter.percent_tf)
               {
                  addWidget(new ZwTextField(offboardingProgressMeter.percent_tf,progressPercent.toString() + "%"));
               }
               if(Boolean(m_window.offboarding_mc.total_tf) && Boolean(totalText))
               {
                  addWidget(new ZwTextField(m_window.offboarding_mc.total_tf,totalText));
               }
            }
         }
         else
         {
            if(m_window.meter_mc)
            {
               progressMeter = m_window.meter_mc;
               addWidget(new ZwBaseWidget(progressMeter));
               progressMeter.gotoAndStop(progressPercent);
               if(progressMeter.percent_tf)
               {
                  addWidget(new ZwTextField(progressMeter.percent_tf,progressPercent.toString() + "%"));
               }
            }
            if(m_window.market_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.market_bt,ZLocUtils.t("Dialogs","ShopNow"),this.openLEWindow));
            }
            if(m_window.description_tf)
            {
               addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs",this.m_featureName + "Description")));
            }
            if(Boolean(m_window.total_tf) && Boolean(totalText))
            {
               addWidget(new ZwTextField(m_window.total_tf,totalText));
            }
            if(m_window.legal_mc)
            {
               addWidget(new FarmAnimatedButton(m_window.legal_mc,this.onLegalClick));
            }
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         Global.player.setSeenFlag(this.m_building.getItemName() + "_seenWindow",true);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(this.m_building,prefixUrl,false,null);
      }
      
      public function onLegalClick(event:Event) : void
      {
         var url:String = ZLocUtils.t("Dialogs",this.m_featureName + "Legal");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function openLEWindow(event:Event) : void
      {
         StatsManager.count(RuntimeDrivenLootableFixedFeatureBuilding.RUNTIME_BUILDING,this.m_featureName,"market_button","click");
         if(this.m_featureName == this.SAVANNAH_CHARITY_BUILDING_NAME)
         {
            UI.displayMarketDialog("unknown","xafcharity");
         }
         else
         {
            UI.displayPopup(new MarketWindow("limited"),false);
         }
         this.close();
      }
      
      private function getDialogAssetPath() : String
      {
         return this.getDialogConfigParam("path");
      }
      
      private function getDialogConfigParam(param:String, required:Boolean = true) : String
      {
         var result:String = null;
         if(Boolean(this.m_dialogConfig) && this.m_dialogConfig.hasOwnProperty(param))
         {
            result = this.m_dialogConfig[param];
         }
         else if(required)
         {
            ErrorManager.addError("RuntimeDrivenCharityWindow:getDialogConfigParam() failed to find required \"" + param + "\" attribute in data");
         }
         return result;
      }
      
      override public function close() : void
      {
         Global.world.dispatchEvent(new DynamicObjectEvent(this.m_building.getItemName() + "_close"));
         super.close();
      }
   }
}

