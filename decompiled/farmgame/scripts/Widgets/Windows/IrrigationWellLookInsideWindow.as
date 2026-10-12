package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.WaterHarvestFManager;
   import Classes.StorageBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class IrrigationWellLookInsideWindow extends MultiStageBuildingDialog
   {
      
      private static const WATER_ICON_URL:String = "assets/newsfeed/market_watericon70.png";
      
      private static const ZLOC_PREFIX:String = "irrigation_well_lookInside_";
      
      private var m_buyMoreWater_bt:FarmAnimatedTextButton;
      
      private var m_fillWellNow_bt:FarmAnimatedCashButton;
      
      private var m_harvestWell_bt:FarmAnimatedTextButton;
      
      private var m_timeToHarvest_tf:ZwTextField;
      
      private var m_completeNowWidget:FarmAnimatedCashButton;
      
      public function IrrigationWellLookInsideWindow(building:StorageBuilding)
      {
         super(building);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var harvester:WaterHarvestFManager = m_featureBuilding.harvester as WaterHarvestFManager;
         if(m_window.main_mc.hasOwnProperty("stage_tf"))
         {
            addWidget(new ZwTextField(m_window.main_mc.stage_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "stageCount",{"current":m_featureBuilding.storageLevel - 1})));
         }
         if(m_window.main_mc.hasOwnProperty("stage_mc"))
         {
            addWidget(new ObjectPreviewFrame(m_window.main_mc.stage_mc,m_featureBuilding.getFarmItem(),null,null,null,"built_" + m_featureBuilding.getCurrentSuffix()));
         }
         if(m_window.main_mc.hasOwnProperty("icon_mc"))
         {
            addWidget(new FarmIcon(m_window.main_mc.icon_mc,WATER_ICON_URL));
         }
         if(Boolean(m_window.main_mc.hasOwnProperty("harvestnumber_tf")) && Boolean(harvester))
         {
            addWidget(new ZwTextField(m_window.main_mc.harvestnumber_tf,harvester.getWaterHarvestAmountForCurrentLevel() + ""));
         }
         if(m_window.main_mc.hasOwnProperty("water_tf"))
         {
            addWidget(new ZwTextField(m_window.main_mc.water_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "water")));
         }
         if(m_window.main_mc.hasOwnProperty("timetoharvest_tf"))
         {
            addWidget(this.m_timeToHarvest_tf = new ZwTextField(m_window.main_mc.timetoharvest_tf,this.getTimeToHarvest()));
         }
         if(m_window.main_mc.hasOwnProperty("buymorewater_bt"))
         {
            addWidget(this.m_buyMoreWater_bt = new FarmAnimatedTextButton(m_window.main_mc.buymorewater_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "buyMoreWater"),this.onClickBuyMoreWater));
         }
         if(m_window.main_mc.hasOwnProperty("fillwellnow_bt"))
         {
            if(m_featureBuilding.instantGrow)
            {
               addWidget(this.m_fillWellNow_bt = new FarmAnimatedCashButton(m_window.main_mc.fillwellnow_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "fillWellNow"),m_featureBuilding.instantGrow.getInstantGrowCost() + "",this.onClickFillNow));
               this.m_fillWellNow_bt.visible = m_featureBuilding.instantGrow.canInstantGrow();
            }
         }
         if(m_window.main_mc.hasOwnProperty("harvest_bt"))
         {
            if(m_featureBuilding.harvester)
            {
               addWidget(this.m_harvestWell_bt = new FarmAnimatedTextButton(m_window.main_mc.harvest_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "harvestWell"),this.onHarvestWellClick));
               this.m_harvestWell_bt.visible = m_featureBuilding.isHarvestable();
            }
         }
         if(!m_featureBuilding.hasReachedMaxExpansionLevel())
         {
            addWidget(new ZwTextField(m_window.main_mc.completeLevel_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "completeLevel")));
            if(m_window.main_mc.hasOwnProperty("completeNow_bt"))
            {
               addWidget(this.m_completeNowWidget = new FarmAnimatedCashButton(m_window.main_mc.completeNow_bt,ZLocUtils.t("Dialogs","CompleteNowCamel"),"00",this.onCompleteNowCallback));
               this.refreshCompleteNow();
            }
         }
      }
      
      private function onCompleteNowCallback(event:Event) : void
      {
         m_featureBuilding.expand.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
         close();
      }
      
      private function refreshCompleteNow() : void
      {
         var cost:int = 0;
         if(Boolean(this.m_completeNowWidget) && Boolean(m_featureBuilding.expand))
         {
            cost = m_featureBuilding.expand.getExpandCashNeeded();
            this.m_completeNowWidget.visible = cost > 0;
            this.m_completeNowWidget.setAmountText(cost + "");
         }
      }
      
      private function getTimeToHarvest() : String
      {
         var timeLeft:Number = NaN;
         var result:String = "";
         if(!m_featureBuilding.isHarvestable())
         {
            timeLeft = m_featureBuilding.getGrowTimeLeft();
            result = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "readyToHarvest",{"time":FarmGameUtil.toFriendlyTime(timeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND)});
         }
         return result;
      }
      
      override protected function getDescriptionText() : String
      {
         var nextStage:int = 0;
         var waterHarvestCount:int = 0;
         var hourCount:int = 0;
         var message:String = "";
         if(m_featureBuilding.hasReachedMaxExpansionLevel())
         {
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "description_maxLevel");
         }
         else
         {
            nextStage = m_featureBuilding.storageLevel;
            waterHarvestCount = (m_featureBuilding.harvester as WaterHarvestFManager).getWaterHarvestAmountForLevel(nextStage + 1);
            hourCount = Math.ceil(m_featureBuilding.getGrowTime() / FarmGameUtil.NUM_MSECS_IN_HOUR);
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "description",{
               "stageCount":nextStage,
               "waterCount":waterHarvestCount,
               "hourCount":hourCount
            });
         }
         return message;
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(this.m_fillWellNow_bt)
         {
            this.m_fillWellNow_bt.setAmountText(m_featureBuilding.instantGrow.getInstantGrowCost() + "");
            this.m_fillWellNow_bt.visible = Boolean(m_featureBuilding.instantGrow) && m_featureBuilding.instantGrow.canInstantGrow();
         }
         if(this.m_harvestWell_bt)
         {
            this.m_harvestWell_bt.visible = m_featureBuilding.isHarvestable();
         }
         if(this.m_timeToHarvest_tf)
         {
            this.m_timeToHarvest_tf.text = this.getTimeToHarvest();
         }
         this.refreshCompleteNow();
      }
      
      private function onClickBuyMoreWater(e:Event) : void
      {
         UI.displayPopup(new GetMoreWaterWindow());
         close();
      }
      
      private function onClickFillNow(e:Event) : void
      {
         if(Boolean(m_featureBuilding.instantGrow) && m_featureBuilding.instantGrow.canInstantGrow())
         {
            m_featureBuilding.instantGrow.promptForInstantGrow(this.onFillNowPromptCallback);
         }
      }
      
      private function onFillNowPromptCallback(performed:Boolean) : void
      {
         this.refreshWindow();
      }
      
      private function onHarvestWellClick(e:Event) : void
      {
         if(m_featureBuilding.isHarvestable())
         {
            m_featureBuilding.harvest();
            this.refreshWindow();
         }
      }
      
      override protected function release() : void
      {
         this.m_buyMoreWater_bt = null;
         this.m_harvestWell_bt = null;
         this.m_fillWellNow_bt = null;
         super.release();
      }
      
      override protected function howDoesThisWorkClick(event:Event) : void
      {
         var prefixUrl:String = m_featureBuilding.getItem().prefixUrl;
         if(prefixUrl != null)
         {
            TutorialUI.displayBuildingTutorialWindow(m_featureBuilding,prefixUrl);
         }
      }
   }
}

