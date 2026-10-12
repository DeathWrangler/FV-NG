package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Helpers.Vector3;
   import Managers.AmsterdamInnovationManager;
   import Managers.Dec19InnovationManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.IsraelInnovationManager;
   import Managers.MadagascarInnovationManager;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Managers.OrderBoard.CasablancaInnovationManager;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Managers.PumpkinPartyInnovationManager;
   import Managers.RussiaInnovationManager;
   import Managers.SouthindiaInnovationManager;
   import Managers.TemplateUIUtility;
   import Managers.TuscanyInnovationManager;
   import Managers.TwentiesInnovationManager;
   import Managers.WinternordInnovationManager;
   import Managers.WreathFestivalInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MultiTreasureHoverOverQuestFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MultiTreasureHoverOverWindow extends HoverOverWindow
   {
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private static const multiTreasureHoverPrefix:String = "multiTreasureHover_";
      
      private static const dreamWorldInnovationSpecialTileText:String = "POT_OF_GOLD_";
      
      private static const OFFSET_X:int = -22;
      
      private static const OFFSET_Y:int = 200;
      
      protected static const WINDOW_ASSET:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf";
      
      private static const ICON_SIZE_X:int = 100;
      
      private static const ICON_SIZE_Y:int = 100;
      
      private var m_slots:MultiTreasureHoverOverQuestFrame;
      
      private var m_part:PartItem = null;
      
      protected var m_treasureBuilding:MultiRewardTreasureConstructionBuilding = null;
      
      protected var m_treasureItem:FarmItem = null;
      
      protected var m_completeNowButton:FarmAnimatedCashButton = null;
      
      private var m_goToFeatureButton:FarmAnimatedTextButton = null;
      
      private var m_unlockButton:FarmAnimatedTextButton = null;
      
      private var m_whatsThis:ZwWidget = null;
      
      private var m_dividerMc:ZwWidget = null;
      
      private var m_rewardContainer1:MovieClip;
      
      private var m_rewardContainer2:MovieClip;
      
      private var m_rewardContainer3:MovieClip;
      
      private var m_timerCheckMark:ZwWidget;
      
      private var m_rewardIcon1:FarmIcon;
      
      private var m_rewardIcon2:FarmIcon;
      
      private var m_rewardIcon3:FarmIcon;
      
      private var m_timerText:ZwTextField;
      
      private var m_timerValueText:ZwTextField;
      
      private var m_rewardText1:ZwTextField;
      
      private var m_rewardText2:ZwTextField;
      
      private var m_rewardText3:ZwTextField;
      
      private var m_bottomRewardDetail:ZwTextField;
      
      private var m_whitewinterReward:ZwTextField;
      
      protected var m_subheaderTextfield:ZwTextField = null;
      
      protected var m_subheader2Textfield:ZwTextField = null;
      
      protected var m_headerTextfield:ZwTextField = null;
      
      protected var m_completeNowCallback:Function = null;
      
      private var m_unlockNowCallback:Function = null;
      
      private var m_goToFeatureCallBack:Function = null;
      
      protected var m_getCashNeededCallback:Function = null;
      
      private var m_allPrereqDetails:Object = null;
      
      private var m_adjacentCheckText:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_stageClickTimer:Timer = null;
      
      private var m_stageClickTimerStopped:Boolean = false;
      
      private var m_startDate:String;
      
      private var m_payerTile:Boolean;
      
      private var m_innovationMC:MovieClip;
      
      private var m_reward_mc:MovieClip;
      
      private var m_hud_mc:MovieClip;
      
      private var m_or_mc:MovieClip;
      
      public function MultiTreasureHoverOverWindow(treasure:MultiRewardTreasureConstructionBuilding, allPrereqDetails:Object, callBackObject:Object, timerTime:int = -1, windowAsset:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf", payerTile:Boolean = false)
      {
         this.m_treasureBuilding = treasure;
         this.m_allPrereqDetails = allPrereqDetails;
         this.m_payerTile = payerTile;
         var originPoint:Vector3 = this.m_treasureBuilding.getPosition();
         var treasureItem:FarmItem = this.m_treasureBuilding.getItem();
         var part:PartItem = this.m_treasureBuilding.getMostNeededItem();
         super(originPoint,windowAsset,timerTime);
         m_offsetY = OFFSET_Y;
         m_offsetX = OFFSET_X;
         this.m_treasureItem = treasureItem;
         this.m_part = part;
         this.refreshCallbacks(callBackObject);
      }
      
      private function refreshCallbacks(callBackObject:Object) : void
      {
         this.m_completeNowCallback = callBackObject["completeNowCallback"];
         this.m_unlockNowCallback = callBackObject["unlockNowCallback"];
         this.m_getCashNeededCallback = callBackObject["getCashNeededCallback"];
         this.m_goToFeatureCallBack = callBackObject["goToFeatureCallback"];
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("timeCheck_mc"))
         {
            this.m_timerCheckMark = addWidget(new ZwWidget(m_window.timeCheck_mc),false) as ZwWidget;
         }
         if(m_window.hasOwnProperty("unlock_bt"))
         {
            addWidget(this.m_unlockButton = new FarmAnimatedTextButton(m_window.unlock_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"Unlock"),this.onClickUnlockNow),true);
         }
         if(m_window.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_completeNowButton = new FarmAnimatedCashButton(m_window.buy_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"BuyNow"),"0",this.onClickCompleteNow),true);
         }
         if(m_window.hasOwnProperty("feature_bt"))
         {
            addWidget(this.m_goToFeatureButton = new FarmAnimatedTextButton(m_window.feature_bt,"Go To Feature",this.onClickgoToFeature),false);
         }
         if(m_window.hasOwnProperty("reward_mc"))
         {
            this.m_reward_mc = m_window["reward_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("hud_mc"))
         {
            this.m_hud_mc = m_window["hud_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("adjacentCheck_tf"))
         {
            this.m_adjacentCheckText = new ZwTextField(m_window.adjacentCheck_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,multiTreasureHoverPrefix + "adjacentCheckText"));
            addWidget(this.m_adjacentCheckText);
         }
         if(m_window.hasOwnProperty("divider_mc"))
         {
            this.m_dividerMc = addWidget(new ZwWidget(m_window.divider_mc),false) as ZwWidget;
         }
         if(m_window.hasOwnProperty("header_tf"))
         {
            this.m_headerTextfield = new ZwTextField(m_window.header_tf,"");
            addWidget(this.m_headerTextfield,true);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.header_tf);
               TemplateUIUtility.applyExpansionBevelFilter(m_window.header_tf);
               TemplateUIUtility.applyExpansionDropShadowFilter(m_window.header_tf);
            }
         }
         if(m_window.hasOwnProperty("timerTask_tf"))
         {
            this.m_timerText = new ZwTextField(m_window.timerTask_tf,"");
            addWidget(this.m_timerText,true);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.timerTask_tf);
            }
         }
         if(m_window.hasOwnProperty("timer_tf"))
         {
            this.m_timerValueText = new ZwTextField(m_window.timer_tf,"");
            addWidget(this.m_timerValueText,true);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.timer_tf);
            }
         }
         if(m_window.hasOwnProperty("subheader2_tf"))
         {
            this.m_subheader2Textfield = new ZwTextField(m_window.subheader2_tf,"");
            addWidget(this.m_subheader2Textfield,true);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.subheader2_tf);
            }
         }
         if(m_window.hasOwnProperty("reward1_mc"))
         {
            this.m_rewardContainer1 = m_window.reward1_mc;
            if(this.m_rewardContainer1.hasOwnProperty("icon1_mc"))
            {
               addWidget(this.m_rewardIcon1 = new FarmIcon(m_window.reward1_mc.icon1_mc),false);
               if(this.m_rewardIcon1)
               {
                  this.m_rewardIcon1.setIconSize(ICON_SIZE_X,ICON_SIZE_Y);
               }
            }
            if(this.m_rewardContainer1.hasOwnProperty("rewardName1_tf"))
            {
               this.m_rewardText1 = new ZwTextField((this.m_rewardContainer1 as MovieClip).rewardName1_tf,"");
               addWidget(this.m_rewardText1,false);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor((this.m_rewardContainer1 as MovieClip).rewardName1_tf);
               }
            }
         }
         if(m_window.hasOwnProperty("reward2_mc"))
         {
            this.m_rewardContainer2 = m_window.reward2_mc;
            if(this.m_rewardContainer2.hasOwnProperty("icon2_mc"))
            {
               addWidget(this.m_rewardIcon2 = new FarmIcon(m_window.reward2_mc.icon2_mc),false);
               if(this.m_rewardIcon2)
               {
                  this.m_rewardIcon2.setIconSize(ICON_SIZE_X,ICON_SIZE_Y);
               }
            }
            if(this.m_rewardContainer2.hasOwnProperty("rewardName2_tf"))
            {
               this.m_rewardText2 = new ZwTextField((this.m_rewardContainer2 as MovieClip).rewardName2_tf,"");
               addWidget(this.m_rewardText2,false);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor((this.m_rewardContainer2 as MovieClip).rewardName2_tf);
               }
            }
         }
         if(m_window.hasOwnProperty("reward3_mc"))
         {
            this.m_rewardContainer3 = m_window.reward3_mc;
            if(this.m_rewardContainer3.hasOwnProperty("fence_icon_mc"))
            {
               addWidget(this.m_rewardIcon3 = new FarmIcon(m_window.reward3_mc.fence_icon_mc),false);
               if(this.m_rewardIcon3)
               {
                  this.m_rewardIcon3.setIconSize(50,50);
               }
            }
            if(this.m_rewardContainer3.hasOwnProperty("fence_tf"))
            {
               this.m_rewardText3 = new ZwTextField((this.m_rewardContainer3 as MovieClip).fence_tf,"");
               addWidget(this.m_rewardText3,false);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor((this.m_rewardContainer3 as MovieClip).fence_tf);
               }
            }
         }
         if(m_window.hasOwnProperty("innovation_mc"))
         {
            this.m_innovationMC = m_window.innovation_mc;
         }
         if(m_window.hasOwnProperty("rewardUnlock_tf"))
         {
            this.m_bottomRewardDetail = new ZwTextField(m_window.rewardUnlock_tf,"");
            addWidget(this.m_bottomRewardDetail,false);
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.rewardUnlock_tf);
            }
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isDragonvalleyInnovationActive() && !DreamWorldInnovationManager.getInstance("DragonvalleyInnovation").isFeatureComplete())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Purchase or unlock this tile to get a 30 point boost in Temple of the Gods!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isAlaskaInnovationActive() && !DreamWorldInnovationManager.getInstance("AlaskaInnovation").isFeatureComplete())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Purchase or unlock this tile to get a 25 point boost in Scout’s Honor!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isCaribbeanInnovationActive() && !CarribeanInnovationManager.getInstance("CarribeanInnovation").isFeatureComplete())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock tiles and harvest them for more fame");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isFrontierInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get more Barn space in Strike It Rich!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isHalloweenInnovationGhoulActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get more Firebolt in Marble’s Mad Machine!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isRussiaInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 50 Karnaval Tickets on tile unlock and use them in The Hammer Whammer!");
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isIsraelInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 30 Bundles of Plenty for the Great Farm-Off!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isWinternordInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 30 Wrapping Papers for the Gifts of Yuletide!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isMadagascarInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 30 Syringes for the Wildlife Hospital!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isTwentiesInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 30 Party Masque for Maggie\'s Party Mania!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isPumpkinPartyInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 30 Spooky Party Hats for Pumpkin Party!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isCasablancaInnovationActive() && (!CasablancaInnovationManager.getInstance("CasablancaInnovation").isFeatureComplete() || CasablancaInnovationManager.getInstance("CasablancaInnovation").isDailyPlayActive()))
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock tiles and harvest them for more Acclaim");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isSouthindiaInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 50 Golden Arrows for The League of Archers!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isDec19InnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 50 Gift Ribbons for The League of Elves!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isCocowonderlandInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 30 Coupons for Cake Me Away!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isIrelandInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get 50 Medieval Axes for Goodwill Shire!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isHalloweenInnovation2019Active())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get more 10 points in Spooks N\' Treats!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isCanadaInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Unlock Tiles to get more 10 points in Animal Retreat!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isAmsterdamInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 50 Flower Cutters for Tulip Tournament!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("innovation_tf") && m_window.hasOwnProperty("points_mc") && this.isWreathFestivalInnovationActive())
         {
            this.m_whitewinterReward = new ZwTextField(m_window.innovation_tf,"Get 50 Wreath Bows for Wreath Festival!");
            addWidget(this.m_whitewinterReward,true);
            m_window["points_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("subheader_tf"))
         {
            this.m_subheaderTextfield = new ZwTextField(m_window.subheader_tf,"");
            addWidget(this.m_subheaderTextfield,false);
         }
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            this.m_whatsThis = addWidget(new ZwWidget(m_window.whatisthis_bt),false) as ZwWidget;
            this.m_whatsThis.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,multiTreasureHoverPrefix + "whatisthis")));
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_slots = new MultiTreasureHoverOverQuestFrame(m_window.slots_mc);
            if(this.m_slots)
            {
               addWidget(this.m_slots);
               if(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SLOT_ITEMS])
               {
                  this.refresh(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SLOT_ITEMS]);
               }
            }
         }
         if(m_window.hasOwnProperty("or_mc"))
         {
            this.m_or_mc = m_window["or_mc"] as MovieClip;
            this.m_or_mc.visible = true;
         }
         this.startStageClickTimer();
         this.updateUI();
         show();
      }
      
      private function updateCompleteButtonVisibilityForTropicalMarket() : void
      {
         if(Boolean(this.m_completeNowButton) && this.shouldHideCompleteButtonOfBuildingForTropicalMarket(this.m_treasureBuilding.getItemName()))
         {
            this.m_completeNowButton.visible = false;
            if(this.m_or_mc)
            {
               this.m_or_mc.visible = false;
            }
         }
         else
         {
            this.m_completeNowButton.visible = true;
            if(this.m_or_mc)
            {
               this.m_or_mc.visible = true;
            }
         }
      }
      
      private function shouldHideCompleteButtonOfBuildingForTropicalMarket(tileName:String) : Boolean
      {
         var tropicalMarketTileRewards:Array = null;
         if(this.isTropicalMarketActive())
         {
            tropicalMarketTileRewards = TropicalMarketInnovationManager.getInstance().tileRewards;
            return tropicalMarketTileRewards.indexOf(tileName) != -1;
         }
         return false;
      }
      
      private function updateCompleteButtonVisibilityForPumpkinParty() : void
      {
         if(Boolean(this.m_completeNowButton) && this.shouldHideCompleteButtonOfBuildingForPumpkinParty(this.m_treasureBuilding.getItemName()))
         {
            this.m_completeNowButton.visible = false;
            if(this.m_or_mc)
            {
               this.m_or_mc.visible = false;
            }
         }
         else
         {
            if(this.m_completeNowButton)
            {
               this.m_completeNowButton.visible = true;
            }
            if(this.m_or_mc)
            {
               this.m_or_mc.visible = true;
            }
         }
      }
      
      private function shouldHideCompleteButtonOfBuildingForPumpkinParty(tileName:String) : Boolean
      {
         var pumkinPartyTileRewards:Array = null;
         if(this.isPumpkinPartyInnovationActive())
         {
            pumkinPartyTileRewards = PumpkinPartyInnovationManager.getInstance().tileRewards;
            return pumkinPartyTileRewards.indexOf(tileName) != -1;
         }
         return false;
      }
      
      private function startStageClickTimer() : void
      {
         if(this.m_stageClickTimer == null)
         {
            this.m_stageClickTimerStopped = false;
            this.m_stageClickTimer = new Timer(3000);
            this.m_stageClickTimer.addEventListener(TimerEvent.TIMER,this.onStageClickTimer);
            this.m_stageClickTimer.start();
         }
      }
      
      private function onStageClickTimer(event:TimerEvent) : void
      {
         if(this.m_stageClickTimer)
         {
            this.m_stageClickTimer.stop();
            this.m_stageClickTimer = null;
            this.m_stageClickTimerStopped = true;
         }
      }
      
      override protected function stageMouseClickHandler(event:MouseEvent) : void
      {
         if(this.m_stageClickTimerStopped)
         {
            this.hide();
         }
      }
      
      public function refresh(quest:Array) : void
      {
         this.m_slots.items = quest;
      }
      
      private function stopRemainingDaysTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
      }
      
      override public function hide() : void
      {
         this.stopRemainingDaysTimer();
         super.hide();
      }
      
      public function beginCloseTimer() : void
      {
         if(m_timerTime > -1)
         {
            m_fadeOutTimer.start();
         }
      }
      
      public function updateAndShow(treasure:MultiRewardTreasureConstructionBuilding, allPrereqDetails:Object, callBackObject:Object, timerTime:int = -1, payerTile:Boolean = false) : void
      {
         this.m_treasureBuilding = treasure;
         this.m_allPrereqDetails = allPrereqDetails;
         this.m_payerTile = payerTile;
         var originPoint:Vector3 = this.m_treasureBuilding.getPosition();
         var treasureItem:FarmItem = this.m_treasureBuilding.getItem();
         var part:PartItem = this.m_treasureBuilding.getMostNeededItem();
         updateOrigin(originPoint);
         this.refreshCallbacks(callBackObject);
         this.m_treasureItem = treasureItem;
         updateTimerUse(timerTime);
         alignWindowOrigin();
         this.startStageClickTimer();
         this.updateUI();
         if(this.m_slots)
         {
            this.refresh(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SLOT_ITEMS]);
         }
         show();
         if(m_timerTime < 0)
         {
            recentlyOpened = true;
         }
      }
      
      private function isDreamWorldInnovationActive() : Boolean
      {
         var m_endTimeStamp:Number = NaN;
         var activeOrNot:Boolean = true;
         var reward:int = FeatureOptionsManager.getInstance().getFeatureOption("DreamWorldInnovation","k11") as int;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML("DreamWorldInnovation");
         if(reward == 0)
         {
            if(config == null)
            {
               activeOrNot = false;
            }
            if(config != null)
            {
               m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]);
               if(m_endTimeStamp < GlobalEngine.serverTime)
               {
                  activeOrNot = false;
               }
            }
         }
         return activeOrNot;
      }
      
      private function isDragonvalleyInnovationActive() : Boolean
      {
         var dragonvalleyInnovationManager:DreamWorldInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("dragonvalley_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            dragonvalleyInnovationManager = DreamWorldInnovationManager.getInstance("DragonvalleyInnovation");
            if(Boolean(dragonvalleyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_DRAGONVALLEY)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isAlaskaInnovationActive() : Boolean
      {
         var dragonvalleyInnovationManager:DreamWorldInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("alaska_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            dragonvalleyInnovationManager = DreamWorldInnovationManager.getInstance("AlaskaInnovation");
            if(Boolean(dragonvalleyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ALASKA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isCaribbeanInnovationActive() : Boolean
      {
         var caribbeanInnovationManager:CarribeanInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("caribbean_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            caribbeanInnovationManager = CarribeanInnovationManager.getInstance("CarribeanInnovation");
            if(Boolean(caribbeanInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CARIBBEAN)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isCasablancaInnovationActive() : Boolean
      {
         var casablancaInnovationManager:CasablancaInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("casablanca_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            casablancaInnovationManager = CasablancaInnovationManager.getInstance("CasablancaInnovation");
            if(Boolean(casablancaInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CASABLANCA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isFrontierInnovationActive() : Boolean
      {
         var result:Boolean = false;
         var manager:FrontierInnovationManager = FrontierInnovationManager.getInstance("FrontierInnovation");
         if(Boolean(manager && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_NEWFRONTIER && !manager.hasExpiryDatePassedForFeature()) && Boolean(!manager.isFeatureComplete()) && !manager.isBarnCapacityReached())
         {
            result = true;
         }
         return result;
      }
      
      private function isHalloweenInnovationGhoulActive() : Boolean
      {
         var InnovationManager:HalloweenInnovationGhoulManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = HalloweenInnovationGhoulManager.getInstance("HalloweenInnovationGhoul");
            if(Boolean(InnovationManager) && Boolean(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HALLOWEENMAD) && InnovationManager.isInventionsCompleted() == false)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isHalloweenInnovation2019Active() : Boolean
      {
         var InnovationManager:Halloween2019InnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovation2019_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = Halloween2019InnovationManager.getInstance("Halloween2019Innovation");
            if(Boolean(InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SPOOKY)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isCanadaInnovationActive() : Boolean
      {
         var InnovationManager:CanadaInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("CanadaInnovation_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            InnovationManager = CanadaInnovationManager.getInstance("CanadaInnovation");
            if(Boolean(InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CANADA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isTuscanyInnovationActive() : Boolean
      {
         var tuscanyInnovationManager:TuscanyInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tuscany_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            tuscanyInnovationManager = TuscanyInnovationManager.getInstance();
            if(Boolean(tuscanyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_TUSCANY)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isRussiaInnovationActive() : Boolean
      {
         var russiaInnovationManager:RussiaInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("russia_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            russiaInnovationManager = RussiaInnovationManager.getInstance();
            if(Boolean(russiaInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_RUSSIA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isIsraelInnovationActive() : Boolean
      {
         var israelInnovationManager:IsraelInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("israel_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            israelInnovationManager = IsraelInnovationManager.getInstance();
            if(Boolean(israelInnovationManager) && Boolean(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ISRAEL) && israelInnovationManager.isFeatureInActivePeriod())
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isWinternordInnovationActive() : Boolean
      {
         var winternordInnovationManager:WinternordInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winternord_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            winternordInnovationManager = WinternordInnovationManager.getInstance();
            if(Boolean(winternordInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_WINTERNORD)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isMadagascarInnovationActive() : Boolean
      {
         var madagascarInnovationManager:MadagascarInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("madagascar_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            madagascarInnovationManager = MadagascarInnovationManager.getInstance();
            if(Boolean(madagascarInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_MADAGASCAR)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isTwentiesInnovationActive() : Boolean
      {
         var twentiesInnovationManager:TwentiesInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("twenties_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            twentiesInnovationManager = TwentiesInnovationManager.getInstance();
            if(Boolean(twentiesInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_TWENTIES)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isSouthindiaInnovationActive() : Boolean
      {
         var southindiaInnovationManager:SouthindiaInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("southindia_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            southindiaInnovationManager = SouthindiaInnovationManager.getInstance();
            if(Boolean(southindiaInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SOUTHINDIA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isDec19InnovationActive() : Boolean
      {
         var dec19InnovationManager:Dec19InnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("dec19_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            dec19InnovationManager = Dec19InnovationManager.getInstance();
            if(Boolean(dec19InnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SANTAVILLAGE)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isCocowonderlandInnovationActive() : Boolean
      {
         var cocowonderlandInnovationManager:CocowonderlandInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("cocowonderland_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            cocowonderlandInnovationManager = CocowonderlandInnovationManager.getInstance();
            if(Boolean(cocowonderlandInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_COCOLAND)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isIrelandInnovationActive() : Boolean
      {
         var irelandInnovationManager:IrelandInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("ireland_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            irelandInnovationManager = IrelandInnovationManager.getInstance();
            if(Boolean(irelandInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_IRELAND)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isAmsterdamInnovationActive() : Boolean
      {
         var amsterdamInnovationManager:AmsterdamInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("amsterdam_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            amsterdamInnovationManager = AmsterdamInnovationManager.getInstance();
            if(Boolean(amsterdamInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_AMSTERDAM)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isWreathFestivalInnovationActive() : Boolean
      {
         var wreathFestivalInnovationManager:WreathFestivalInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("wreathfestival_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            wreathFestivalInnovationManager = WreathFestivalInnovationManager.getInstance();
            if(Boolean(wreathFestivalInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_YULETIDE)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isTropicalMarketActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tropical_market_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(TropicalMarketInnovationManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ALOHA)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isPumpkinPartyInnovationActive() : Boolean
      {
         var pumpkinpartyInnovationManager:PumpkinPartyInnovationManager = null;
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("pumpkinparty_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            pumpkinpartyInnovationManager = PumpkinPartyInnovationManager.getInstance();
            if(Boolean(pumpkinpartyInnovationManager) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_PUMPKIN)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function setExpiryDateText() : void
      {
         var timeLockedText:String = null;
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_startDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(timeRemaining > 0)
         {
            if(this.m_timerText)
            {
               timeLockedText = ZLocUtils.t("Dialogs",Global.worldManager.currentWorldUniqueMarketCard + "_" + multiTreasureHoverPrefix + "timeLocked");
               if(!timeLockedText || Boolean(timeLockedText) && Boolean(timeLockedText == ""))
               {
                  timeLockedText = ZLocUtils.t("Dialogs",multiTreasureHoverPrefix + "timeLocked");
               }
               this.m_timerText.text = timeLockedText;
               this.m_timerText.visible = true;
            }
            if(numDays > 1)
            {
               if(this.m_timerValueText)
               {
                  this.m_timerValueText.text = numDays + " " + ZLocUtils.t("Dialogs","Days");
                  this.m_timerValueText.visible = true;
               }
            }
            else
            {
               if(this.m_timer == null)
               {
                  this.m_timer = new Timer(1000);
                  this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
                  this.m_timer.start();
               }
               if(this.m_timerValueText)
               {
                  this.m_timerValueText.text = HUD.getformattedTimeLeft(timeRemaining);
                  this.m_timerValueText.visible = true;
               }
            }
         }
         else
         {
            this.setExpiredText();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.setExpiryDateText();
      }
      
      private function setExpiredText() : void
      {
         var timeUnlockedText:String = ZLocUtils.t("Dialogs",Global.worldManager.currentWorldUniqueMarketCard + "_" + multiTreasureHoverPrefix + "timeUnlocked");
         if(!timeUnlockedText || Boolean(timeUnlockedText) && Boolean(timeUnlockedText == ""))
         {
            timeUnlockedText = ZLocUtils.t("Dialogs",multiTreasureHoverPrefix + "timeUnlocked");
         }
         if(this.m_timerText)
         {
            this.m_timerText.text = timeUnlockedText;
         }
         if(this.m_timerValueText)
         {
            this.m_timerValueText.visible = false;
         }
         if(this.m_timerCheckMark)
         {
            this.m_timerCheckMark.visible = true;
         }
      }
      
      private function updateUI() : void
      {
         var reward:int = 0;
         var treasureName:String = null;
         var cashneeded:int = 0;
         var rewards:Array = null;
         var rewardsFence:Array = null;
         var rewardItem:FarmItem = null;
         var fenceCount:String = null;
         var locked:String = this.m_treasureBuilding.getFailedContextPrereq();
         if(this.m_timerCheckMark)
         {
            this.m_timerCheckMark.visible = false;
         }
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         if(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.START_TIME])
         {
            this.m_startDate = this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.START_TIME];
            this.setExpiryDateText();
         }
         else
         {
            this.setExpiredText();
         }
         if(this.m_subheader2Textfield)
         {
            if(this.m_payerTile)
            {
               this.m_subheader2Textfield.text = ZLocUtils.t("Dialogs",multiTreasureHoverPrefix + "payerText",{"tileName":this.m_treasureItem.friendlyTitle});
               this.m_subheader2Textfield.visible = true;
               if(this.m_subheaderTextfield)
               {
                  this.m_subheaderTextfield.visible = false;
               }
            }
            else
            {
               this.m_subheader2Textfield.visible = false;
            }
         }
         if(locked == null)
         {
            if(this.m_unlockButton)
            {
               this.m_unlockButton.enabled = true;
            }
         }
         else if(this.m_unlockButton)
         {
            this.m_unlockButton.enabled = false;
         }
         if(this.m_goToFeatureButton)
         {
            this.m_subheaderTextfield.visible = true;
            reward = FeatureOptionsManager.getInstance().getFeatureOption("DreamWorldInnovation","k11") as int;
            treasureName = (this.m_treasureItem as BuildingItem).buildingName;
            if(treasureName == "xdw_tile_special")
            {
               switch(reward)
               {
                  case 0:
                     this.m_goToFeatureButton.visible = true;
                     this.m_goToFeatureButton.text = "Go To Race!";
                     break;
                  case 1:
                     this.m_goToFeatureButton.visible = true;
                     this.m_goToFeatureButton.text = "Unlock for Free";
                     break;
                  case 2:
                  case 3:
                  case 4:
                     this.m_goToFeatureButton.visible = false;
                     this.m_completeNowButton.visible = true;
               }
               if(!this.isDreamWorldInnovationActive())
               {
                  this.m_goToFeatureButton.visible = false;
               }
            }
         }
         if(this.m_completeNowButton)
         {
            if(treasureName == "xdw_tile_special")
            {
               this.m_completeNowButton.element.amount_full_tf.text = this.m_getCashNeededCallback().toString();
               cashneeded = this.m_getCashNeededCallback();
               switch(reward)
               {
                  case 0:
                  case 1:
                     this.m_completeNowButton.visible = false;
                     break;
                  case 2:
                     this.m_completeNowButton.setAmountText(int(cashneeded * 0.4).toString());
                     break;
                  case 3:
                     this.m_completeNowButton.setAmountText(int(cashneeded * 0.6).toString());
                     break;
                  case 4:
                     this.m_completeNowButton.setAmountText(int(cashneeded * 0.8).toString());
               }
               if(this.m_unlockButton)
               {
                  this.m_completeNowButton.enabled = !this.m_unlockButton.enabled;
               }
               else
               {
                  this.m_completeNowButton.enabled = true;
               }
            }
            else
            {
               this.m_completeNowButton.setAmountText(this.m_getCashNeededCallback().toString());
               if(this.m_unlockButton)
               {
                  this.m_completeNowButton.enabled = !this.m_unlockButton.enabled;
               }
               else
               {
                  this.m_completeNowButton.enabled = true;
               }
            }
         }
         if(this.m_subheaderTextfield)
         {
            if(treasureName == "xdw_tile_special")
            {
               switch(reward)
               {
                  case 0:
                     this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_notcomplete");
                     break;
                  case 1:
                     this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_first");
                     break;
                  case 2:
                     this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_second");
                     break;
                  case 3:
                     this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_third");
                     break;
                  case 4:
                     this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_fourth");
               }
               if(!this.isDreamWorldInnovationActive())
               {
                  this.m_subheaderTextfield.text = ZLocUtils.t("Dialogs",dreamWorldInnovationSpecialTileText + "subheader_featureexpired");
               }
            }
         }
         if(this.m_reward_mc)
         {
            if(treasureName == "xdw_tile_special")
            {
               switch(reward)
               {
                  case 0:
                     this.m_reward_mc.visible = false;
                     break;
                  case 1:
                     this.m_reward_mc.visible = true;
                     this.m_reward_mc.gotoAndStop(1);
                     break;
                  case 2:
                     this.m_reward_mc.visible = true;
                     this.m_reward_mc.gotoAndStop(2);
                     break;
                  case 3:
                     this.m_reward_mc.visible = true;
                     this.m_reward_mc.gotoAndStop(3);
                     break;
                  case 4:
                     this.m_reward_mc.visible = true;
                     this.m_reward_mc.gotoAndStop(4);
               }
            }
         }
         if(this.m_hud_mc)
         {
            if(treasureName == "xdw_tile_special")
            {
               switch(reward)
               {
                  case 0:
                     this.m_hud_mc.visible = true;
                     break;
                  case 1:
                     this.m_hud_mc.visible = false;
                     break;
                  case 2:
                     this.m_hud_mc.visible = false;
                     break;
                  case 3:
                     this.m_hud_mc.visible = false;
                     break;
                  case 4:
                     this.m_hud_mc.visible = false;
               }
            }
         }
         if(this.m_dividerMc)
         {
            this.m_dividerMc.visible = this.m_payerTile ? false : true;
         }
         if(this.m_whatsThis)
         {
            this.m_whatsThis.visible = this.m_payerTile ? false : true;
         }
         if(Boolean(this.m_headerTextfield) && Boolean(this.m_treasureItem))
         {
            this.m_headerTextfield.text = this.m_treasureItem.friendlyTitle;
         }
         this.hideAllRewardContainers();
         if(this.m_allPrereqDetails)
         {
            if(Boolean(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SHOULD_SHOW_ADJACENT_TEXT]) && this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SHOULD_SHOW_ADJACENT_TEXT] == 1)
            {
               if(this.m_adjacentCheckText)
               {
                  this.m_adjacentCheckText.visible = true;
                  if(this.m_completeNowButton)
                  {
                     this.m_completeNowButton.enabled = false;
                  }
                  if(this.m_unlockButton)
                  {
                     this.m_unlockButton.enabled = false;
                  }
               }
            }
            else if(this.m_adjacentCheckText)
            {
               this.m_adjacentCheckText.visible = false;
            }
            if(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.REWARDS])
            {
               rewards = this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.REWARDS];
               rewardsFence = this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.REWARDS_FENCE];
               rewardItem = null;
               if(rewards[0])
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewards[0]);
                  if(rewardItem)
                  {
                     if(this.m_rewardContainer1)
                     {
                        this.m_rewardContainer1.visible = true;
                     }
                     if(this.m_rewardIcon1)
                     {
                        this.m_rewardIcon1.loadIcon(rewardItem.icon);
                        this.m_rewardIcon1.setIconSize(ICON_SIZE_X,ICON_SIZE_Y);
                        this.m_rewardIcon1.visible = true;
                     }
                     if(this.m_rewardText1)
                     {
                        this.m_rewardText1.text = rewardItem.friendlyTitle;
                        this.m_rewardText1.visible = true;
                     }
                  }
               }
               if(rewards[1])
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewards[1]);
                  if(rewardItem)
                  {
                     if(this.m_rewardContainer2)
                     {
                        this.m_rewardContainer2.visible = true;
                     }
                     if(this.m_rewardIcon2)
                     {
                        this.m_rewardIcon2.loadIcon(rewardItem.icon);
                        this.m_rewardIcon2.setIconSize(ICON_SIZE_X,ICON_SIZE_Y);
                        this.m_rewardIcon2.visible = true;
                     }
                     if(this.m_rewardText2)
                     {
                        this.m_rewardText2.text = rewardItem.friendlyTitle;
                        this.m_rewardText2.visible = true;
                     }
                  }
               }
               if(rewardsFence != null)
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardsFence[0]);
                  if(rewardItem)
                  {
                     if(this.m_rewardContainer3)
                     {
                        this.m_rewardContainer3.visible = true;
                     }
                     if(this.m_rewardIcon3)
                     {
                        this.m_rewardIcon3.loadIcon(rewardItem.icon);
                        this.m_rewardIcon3.setIconSize(50,50);
                        this.m_rewardIcon3.visible = true;
                     }
                     if(this.m_rewardText3)
                     {
                        fenceCount = this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.FENCE_COUNT];
                        this.m_rewardText3.text = "Also get " + fenceCount + " free fences";
                        this.m_rewardText3.visible = true;
                     }
                  }
               }
               if(this.m_allPrereqDetails[MultiRewardTreasureConstructionBuilding.SHOULD_SHOW_JMINNOVATION_GA])
               {
                  if(this.m_innovationMC)
                  {
                     this.m_innovationMC.visible = true;
                  }
               }
               else if(this.m_innovationMC)
               {
                  this.m_innovationMC.visible = false;
               }
            }
         }
         if(Boolean(this.m_whitewinterReward) && Boolean(m_window.hasOwnProperty("points_mc")) && Boolean(this.m_completeNowButton))
         {
            if(this.m_completeNowButton.enabled)
            {
               this.m_whitewinterReward.visible = true;
               m_window["points_mc"].visible = true;
            }
            else
            {
               this.m_whitewinterReward.visible = false;
               m_window["points_mc"].visible = false;
            }
         }
         if(this.isTropicalMarketActive())
         {
            this.updateCompleteButtonVisibilityForTropicalMarket();
         }
         else if(this.isPumpkinPartyInnovationActive())
         {
            this.updateCompleteButtonVisibilityForPumpkinParty();
         }
      }
      
      private function hideAllRewardContainers() : void
      {
         if(this.m_rewardContainer1)
         {
            this.m_rewardContainer1.visible = false;
         }
         if(this.m_bottomRewardDetail)
         {
            this.m_bottomRewardDetail.visible = false;
         }
         if(this.m_rewardContainer2)
         {
            this.m_rewardContainer2.visible = false;
         }
         if(this.m_rewardContainer3)
         {
            this.m_rewardContainer3.visible = false;
         }
      }
      
      private function onClickCompleteNow(e:MouseEvent) : void
      {
         this.m_completeNowCallback();
         this.hide();
         FarmStatsManager.count("expand_treasure_farm",(this.m_treasureItem as BuildingItem).buildingName,"hover_menu_clicked","complete_now");
      }
      
      private function onClickUnlockNow(e:MouseEvent) : void
      {
         var tileName:String = null;
         this.m_unlockNowCallback();
         this.hide();
         FarmStatsManager.count("expand_treasure_farm",(this.m_treasureItem as BuildingItem).buildingName,"hover_menu_clicked","unlock");
         if(this.isTropicalMarketActive())
         {
            tileName = this.m_treasureBuilding.getItemFriendlyName();
            FarmStatsManager.count("TropicalMarketInnovation","LandTile",tileName,"Unlock");
         }
         if(this.isPumpkinPartyInnovationActive())
         {
            tileName = this.m_treasureBuilding.getItemFriendlyName();
            FarmStatsManager.count("PumpkinPartyInnovation","LandTile",tileName,"Unlock");
         }
      }
      
      private function onClickgoToFeature(e:MouseEvent) : void
      {
         var reward:int = FeatureOptionsManager.getInstance().getFeatureOption("DreamWorldInnovation","k11") as int;
         if(reward == 0)
         {
            DreamWorldInnovationManager.getInstance("DreamWorldInnovation").showMainUI();
         }
         else if(reward == 1)
         {
            this.onClickUnlockNow(e);
         }
         this.hide();
      }
   }
}

