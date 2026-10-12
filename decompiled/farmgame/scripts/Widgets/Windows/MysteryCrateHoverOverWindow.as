package Widgets.Windows
{
   import Classes.MysteryCrateBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Helpers.Vector3;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class MysteryCrateHoverOverWindow extends HoverOverWindow
   {
      
      protected static const WINDOW_ASSET:String = "assets/dialogs/FV_mysteryCrate2015_tooltip_v1.swf";
      
      private static const HOVER_MENU_TIME_MS:int = 800;
      
      private static const OFFSET_X:int = -45;
      
      private static const OFFSET_Y:int = 200;
      
      private static const ICON_SCALE:Number = 1;
      
      private static const ICON_OFFSET_X:int = 0;
      
      private static const ICON_OFFSET_Y:int = 0;
      
      private var m_part:PartItem = null;
      
      private var m_partIcon:FarmIcon = null;
      
      private var m_howItWorksCallBack:Function = null;
      
      private var m_completeNowCallback:Function = null;
      
      private var m_completeNowButton:FarmAnimatedCashButton = null;
      
      private var m_howItWorks:FarmAnimatedButton = null;
      
      private var m_askForMoreButton:FarmAnimatedTextButton = null;
      
      private var m_usePartsButton:FarmAnimatedTextButton = null;
      
      private var m_partsAddedSoFar:ZwTextField = null;
      
      private var m_timeLeft:ZwTextField = null;
      
      private var m_availableParts:ZwTextField = null;
      
      private var m_getCashNeededCallback:Function = null;
      
      private var m_getTotalPartsCountCallback:Function = null;
      
      private var m_getCurrentPartsCountCallback:Function = null;
      
      private var m_getCurrentGiftPartsCountCallback:Function = null;
      
      private var m_usePartsCallBack:Function = null;
      
      private var m_getExpiryTimeCallback:Function = null;
      
      private var m_askForMoreCallback:Function = null;
      
      private var m_feedPostingState:String = "";
      
      public function MysteryCrateHoverOverWindow(originPoint:Vector3, item:FarmItem, part:PartItem, feedPostingState:String, callBackObject:Object)
      {
         super(originPoint,WINDOW_ASSET,HOVER_MENU_TIME_MS);
         m_offsetY = OFFSET_Y;
         m_offsetX = OFFSET_X;
         this.m_feedPostingState = feedPostingState;
         this.m_part = part;
         this.refreshCallbacks(callBackObject);
      }
      
      private function refreshCallbacks(callBackObject:Object) : void
      {
         this.m_howItWorksCallBack = callBackObject["howItWorksCallback"];
         this.m_completeNowCallback = callBackObject["completeNowCallback"];
         this.m_getCashNeededCallback = callBackObject["getCashNeededCallback"];
         this.m_getTotalPartsCountCallback = callBackObject["getTotalPartsCallback"];
         this.m_getCurrentPartsCountCallback = callBackObject["getCurrentPartsCallback"];
         this.m_getExpiryTimeCallback = callBackObject["getExpiryTimeCallback"];
         this.m_askForMoreCallback = callBackObject["askForHelpCallback"];
         this.m_getCurrentGiftPartsCountCallback = callBackObject["getCurrentGiftPartsCallback"];
         this.m_usePartsCallBack = callBackObject["usePartsCallBack"];
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(ObjectUtil.pathExists(m_window,"main_mc"))
         {
            m_window.main_mc.visible = true;
            this.m_partsAddedSoFar = new ZwTextField(m_window.main_mc.count_tf,this.getProgressText(this.m_part.item));
            this.m_howItWorks = new FarmAnimatedButton(m_window.main_mc.whatisthis_mc,this.onClickHowItWorks);
            this.m_completeNowButton = new FarmAnimatedCashButton(m_window.main_mc.complete_bt,ZLocUtils.t("Dialogs","storage_complete_now"),"0",this.onClickCompleteNow);
            if(Global.flashHotParams["MYSTERY_CRATE_VIRAL_CHANNEL"] == MysteryCrateBuilding.ASK_PARTS_FEED && this.m_feedPostingState == MysteryCrateBuilding.FEED_STATUS_POSTED)
            {
               this.m_askForMoreButton = new FarmAnimatedTextButton(m_window.main_mc.ask_bt,ZLocUtils.t("Dialogs","Posted"));
               this.m_askForMoreButton.enabled = false;
            }
            else
            {
               this.m_askForMoreButton = new FarmAnimatedTextButton(m_window.main_mc.ask_bt,ZLocUtils.t("Dialogs","mysterycrate_ask_for_help_button"),this.onClickAskForMore);
               this.m_askForMoreButton.enabled = true;
            }
            this.m_usePartsButton = new FarmAnimatedTextButton(m_window.main_mc.use_bt,ZLocUtils.t("Dialogs","Use"),this.onUseParts);
            this.m_usePartsButton.enabled = this.m_getCurrentGiftPartsCountCallback(this.m_part.item) > 0 ? true : false;
            this.m_timeLeft = new ZwTextField(m_window.main_mc.time_tf,this.getExpiryText());
            this.m_availableParts = new ZwTextField(m_window.main_mc.available_tf,ZLocUtils.t("Dialogs","mysterycrate_available_text",{"quantity":this.m_getCurrentGiftPartsCountCallback(this.m_part.item)}));
            addWidget(this.m_partsAddedSoFar);
            addWidget(this.m_howItWorks);
            addWidget(this.m_completeNowButton);
            addWidget(this.m_askForMoreButton);
            addWidget(this.m_availableParts);
            addWidget(this.m_usePartsButton);
            this.refreshIcon();
            this.updateUI();
            show();
         }
      }
      
      private function getProgressText(item:FarmItem) : String
      {
         return ZLocUtils.t("Dialogs","mysterycrate_part_progress",{
            "current":this.m_getCurrentPartsCountCallback(item) % int(this.m_getTotalPartsCountCallback() / 3),
            "total":int(this.m_getTotalPartsCountCallback() / 3)
         });
      }
      
      private function getExpiryText() : String
      {
         return this.m_getExpiryTimeCallback();
      }
      
      private function updateUI() : void
      {
         if(this.m_completeNowButton)
         {
            this.m_completeNowButton.setAmountText(this.m_getCashNeededCallback().toString());
         }
         if(this.m_partsAddedSoFar)
         {
            this.m_partsAddedSoFar.text = this.getProgressText(this.m_part.item);
         }
         if(this.m_availableParts)
         {
            this.m_availableParts.text = ZLocUtils.t("Dialogs","mysterycrate_available_text",{
               "quantity":this.m_getCurrentGiftPartsCountCallback(this.m_part.item),
               "itemName":this.m_part.item.name
            });
         }
      }
      
      private function refreshIcon() : void
      {
         this.m_partIcon = new FarmIcon(m_window.main_mc.icon_mc,this.m_part.item.icon);
         this.m_partIcon.setIconScale(ICON_SCALE,ICON_SCALE);
         this.m_partIcon.x += ICON_OFFSET_X;
         this.m_partIcon.y += ICON_OFFSET_Y;
         addWidget(this.m_partIcon);
      }
      
      public function beginCloseTimer() : void
      {
         if(m_timerTime > -1)
         {
            m_fadeOutTimer.start();
         }
      }
      
      override protected function mouseOver(e:MouseEvent) : void
      {
         super.mouseOver(e);
      }
      
      private function onClickHowItWorks(e:MouseEvent) : void
      {
         FarmStatsManager.count(MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.CLICKED_CONTEXT_MENU_STAT,MysteryCrateBuilding.WHAT_IS_THIS_STAT);
         this.m_howItWorksCallBack();
         hide();
      }
      
      private function onClickCompleteNow(e:MouseEvent) : void
      {
         FarmStatsManager.count(MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.CLICKED_CONTEXT_MENU_STAT,MysteryCrateBuilding.COMPLETE_NOW_STAT);
         this.m_completeNowCallback();
         hide();
      }
      
      private function onUseParts(e:MouseEvent) : void
      {
         this.m_usePartsCallBack(this.m_part.item);
         this.updateUI();
      }
      
      private function onClickAskForMore(e:MouseEvent) : void
      {
         FarmStatsManager.count(MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.MYSTERY_CRATE,MysteryCrateBuilding.CLICKED_CONTEXT_MENU_STAT,MysteryCrateBuilding.ASK_PARTS_STAT);
         if(this.m_feedPostingState == MysteryCrateBuilding.FEED_STATUS_READY || Global.flashHotParams["MYSTERY_CRATE_VIRAL_CHANNEL"] != MysteryCrateBuilding.ASK_PARTS_FEED)
         {
            this.m_askForMoreCallback();
         }
         hide();
      }
   }
}

