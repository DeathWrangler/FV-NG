package Classes
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.FarmDynamicDialog;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class EnglandUnwitherClock extends Decoration
   {
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static var DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      protected const MENU_ACTION_BUYTIME:String = "unwither_buy";
      
      protected const RECHARGE_LENGTH_DAYS:uint = 30;
      
      protected const RECHARGE_LENGTH_SEC:uint = 2592000;
      
      protected const ITEMFLAG_1WEEK:String = "EnglandUnwitherClock_1Week";
      
      protected const ITEMFLAG_1DAY:String = "EnglandUnwitherClock_1Day";
      
      protected const ITEMFLAG_VALUE_SET:String = "set";
      
      protected const ITEMFLAG_VALUE_UNSET:String = "";
      
      protected const KINGDOM:String = "unwither_clock_recharge";
      
      protected const KINGDOM_IMPULSE:String = "unwither_clock_recharge_impulse";
      
      protected var m_buyDialog:FarmDynamicDialog = null;
      
      protected var m_impulseDialog:ImpulseBuy = null;
      
      protected var m_protectionEndTs:uint = 0;
      
      protected var m_incrRechargeCost:int = 45;
      
      protected var m_numDaysRequested:int = 30;
      
      protected var m_secondsRemaining:int = 0;
      
      protected var m_daysRemaining:uint = 0;
      
      protected var m_tooltipText:String = "";
      
      protected var m_hasPoppedDialog:Boolean = false;
      
      protected var m_itemFlag:String = null;
      
      protected var m_arrow:DisplayObject = null;
      
      protected var m_setPlaced:Boolean = false;
      
      protected var m_haveMadeTimeCalc:Boolean = false;
      
      public function EnglandUnwitherClock(itemName:String = null)
      {
         super(itemName);
      }
      
      protected function updateTimeCalculations() : void
      {
         this.m_secondsRemaining = 0;
         this.m_daysRemaining = 0;
         var now:uint = this.nowInSeconds();
         if(this.m_protectionEndTs > now)
         {
            this.m_secondsRemaining = this.m_protectionEndTs - now;
            this.m_daysRemaining = this.m_secondsRemaining / FarmGameUtil.NUM_SECS_IN_DAY;
         }
         this.m_tooltipText = ZLocUtils.tk_pk_asTitle(getItemFriendlyName()) + ": ";
         if(0 == this.m_secondsRemaining)
         {
            this.m_tooltipText += ZLocUtils.t("Dialogs","UnwitherClock_ToolTip_Expired");
         }
         else if(0 == this.m_daysRemaining)
         {
            this.m_tooltipText += ZLocUtils.t("Dialogs","UnwitherClock_ToolTip_Expiring");
         }
         else
         {
            this.m_tooltipText += ZLocUtils.t("Dialogs","UnwitherClock_ToolTip_Days",{
               "quantity":this.m_daysRemaining,
               "dayword":ZLocUtils.tk("SocialMission","day_word","",this.m_daysRemaining)
            });
         }
         var itemFlag:String = null;
         if(1 >= this.m_daysRemaining && this.ITEMFLAG_VALUE_SET != Global.player.getItemFlag(this.ITEMFLAG_1DAY))
         {
            itemFlag = this.ITEMFLAG_1DAY;
         }
         else if(7 > this.m_daysRemaining && this.ITEMFLAG_VALUE_SET != Global.player.getItemFlag(this.ITEMFLAG_1WEEK))
         {
            itemFlag = this.ITEMFLAG_1WEEK;
         }
         if(null != itemFlag && !this.m_setPlaced)
         {
            this.m_itemFlag = itemFlag;
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("protectionEndTs"))
         {
            this.m_protectionEndTs = uint(data.protectionEndTs);
         }
         if(data.hasOwnProperty("rechargeCost"))
         {
            this.m_incrRechargeCost = int(data.rechargeCost);
         }
      }
      
      override public function setPlaced(placed:Boolean) : void
      {
         super.setPlaced(placed);
         this.m_setPlaced = true;
         if(placed && 0 == this.m_protectionEndTs)
         {
            this.setProtectionEndTs(this.nowInSeconds() + this.RECHARGE_LENGTH_SEC);
         }
      }
      
      protected function setProtectionEndTs(endTs:uint) : void
      {
         this.m_protectionEndTs = endTs;
         Global.player.setItemFlag(this.ITEMFLAG_1DAY,this.ITEMFLAG_VALUE_UNSET);
         Global.player.setItemFlag(this.ITEMFLAG_1WEEK,this.ITEMFLAG_VALUE_UNSET);
         this.updateTimeCalculations();
         if(this.m_secondsRemaining)
         {
            Global.world.growAllPlots();
         }
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return false;
      }
      
      override protected function updateToolTipText() : void
      {
         if(GlobalEngine.isServerTimeValid() && !this.m_haveMadeTimeCalc)
         {
            this.updateTimeCalculations();
            this.m_haveMadeTimeCalc = true;
         }
         if(isHighlighted())
         {
            m_toolTipOverride = this.m_tooltipText;
         }
         else
         {
            m_toolTipOverride = "";
         }
         return super.updateToolTipText();
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = super.getMenuItems();
         menuArray.push({
            "label":ZLocUtils.t("Dialogs","UnwitherClock_BuyMenu"),
            "action":this.MENU_ACTION_BUYTIME
         });
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.MENU_ACTION_BUYTIME:
                  this.showBuyDialog();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function get hasPoppedDialog() : Boolean
      {
         return this.m_hasPoppedDialog;
      }
      
      public function showBuyDialog() : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.KINGDOM,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         this.m_numDaysRequested = this.RECHARGE_LENGTH_DAYS;
         var shortcuts:Array = new Array({
            "name":"title",
            "text":ZLocUtils.tk_pk_asTitle(getItemFriendlyName())
         },{
            "name":"cashcost",
            "text":"" + this.m_incrRechargeCost
         },{
            "name":"reqdays",
            "text":"" + this.m_numDaysRequested
         },{
            "name":"timeleft",
            "locId":"Dialogs:UnwitherClock_Buy_TimeLeft"
         },{
            "name":"description",
            "locId":"Dialogs:UnwitherClock_Buy_Description"
         },{
            "name":"ndays",
            "locId":"Dialogs:UnwitherClock_Buy_Ndays",
            "params":{
               "quantity":this.m_daysRemaining,
               "dayword":ZLocUtils.tk("SocialMission","day_word","",this.m_daysRemaining)
            }
         },{
            "name":"buyprompt",
            "locId":"Dialogs:UnwitherClock_Buy_BuyPrompt",
            "params":{"quantity":this.m_incrRechargeCost}
         },{
            "name":"okButton",
            "locId":"Dialogs:UnwitherClock_Buy_OkButton",
            "buttonPress":this.onBuyDialogOkButton
         },{
            "name":"upButton",
            "buttonPress":this.onBuyDialogUpButton
         },{
            "name":"downButton",
            "buttonPress":this.onBuyDialogDownButton
         },{
            "name":"cancelButton",
            "locId":"Dialogs:UnwitherClock_Buy_CancelButton",
            "buttonPress":this.onBuyDialogCancelButton
         });
         this.removeArrowIndicator();
         this.m_buyDialog = FarmDynamicDialog.createDialog("UnwitherClockBuy",FarmDynamicDialog);
         this.m_buyDialog.setup();
         for(var i:* = int(shortcuts.length - 1); 0 <= i; i--)
         {
            if(null != shortcuts[i].locId)
            {
               this.m_buyDialog.setShortcutAttribute(shortcuts[i].name,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t_pk(shortcuts[i].locId,"",shortcuts[i].params));
            }
            else if(null != shortcuts[i].text)
            {
               this.m_buyDialog.setShortcutAttribute(shortcuts[i].name,TextFieldView.ATTRIBUTE_TEXT,shortcuts[i].text);
            }
            if(null != shortcuts[i].buttonPress)
            {
               this.m_buyDialog.setShortcutListener(shortcuts[i].name,WidgetControllerEvent.BUTTON_PRESSED,shortcuts[i].buttonPress);
            }
         }
         this.m_buyDialog.show();
         if(null != this.m_itemFlag)
         {
            Global.player.setItemFlag(this.m_itemFlag,this.ITEMFLAG_VALUE_SET);
            this.m_itemFlag = null;
         }
      }
      
      protected function onBuyDialogOkButton(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.KINGDOM,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM);
         this.m_buyDialog.destroy();
         this.m_buyDialog = null;
         var numRechargesRequested:int = this.m_numDaysRequested / this.RECHARGE_LENGTH_DAYS;
         var totalCost:int = numRechargesRequested * this.m_incrRechargeCost;
         if(Global.player.cash >= totalCost)
         {
            Global.player.cash -= totalCost;
            TransactionManager.addTransaction(new TBuyTime(numRechargesRequested));
            if(0 == this.m_secondsRemaining)
            {
               this.setProtectionEndTs(this.nowInSeconds() + this.RECHARGE_LENGTH_SEC * numRechargesRequested);
            }
            else
            {
               this.setProtectionEndTs(this.m_protectionEndTs + this.RECHARGE_LENGTH_SEC * numRechargesRequested);
            }
         }
         else
         {
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.KINGDOM_IMPULSE,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",0,this.KINGDOM_IMPULSE);
         }
      }
      
      private function updateReqInfoDisplay() : void
      {
         var curCost:int = 0;
         if(this.m_buyDialog)
         {
            this.m_buyDialog.setShortcutAttribute("reqdays",TextFieldView.ATTRIBUTE_TEXT,"" + this.m_numDaysRequested);
            curCost = this.m_numDaysRequested / this.RECHARGE_LENGTH_DAYS * this.m_incrRechargeCost;
            this.m_buyDialog.setShortcutAttribute("cashcost",TextFieldView.ATTRIBUTE_TEXT,"" + curCost);
         }
      }
      
      protected function onBuyDialogUpButton(event:WidgetControllerEvent) : void
      {
         this.m_numDaysRequested += this.RECHARGE_LENGTH_DAYS;
         this.updateReqInfoDisplay();
      }
      
      protected function onBuyDialogDownButton(event:WidgetControllerEvent) : void
      {
         if(this.m_numDaysRequested > this.RECHARGE_LENGTH_DAYS)
         {
            this.m_numDaysRequested -= this.RECHARGE_LENGTH_DAYS;
            this.updateReqInfoDisplay();
         }
      }
      
      protected function onBuyDialogCancelButton(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.KINGDOM,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         this.m_buyDialog.destroy();
         this.m_buyDialog = null;
      }
      
      protected function nowInSeconds() : uint
      {
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         this.checkArrowIndicator();
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkArrowIndicator();
      }
      
      private function checkArrowIndicator() : void
      {
         var spr:Sprite = null;
         if(!m_usingLoadingGraphic && !UI.isShowingPopup())
         {
            if(GlobalEngine.isServerTimeValid() && !this.m_haveMadeTimeCalc)
            {
               this.updateTimeCalculations();
               this.m_haveMadeTimeCalc = true;
            }
            if(this.m_itemFlag != null && !this.m_setPlaced)
            {
               spr = m_displayObject as Sprite;
               if(this.m_arrow == null && spr.numChildren > 0)
               {
                  this.m_arrow = this.createArrowIndicator();
                  if(this.m_arrow)
                  {
                     this.m_arrow.visible = true;
                     (m_displayObject as Sprite).addChild(this.m_arrow);
                     this.setArrowPosition();
                  }
               }
            }
         }
      }
      
      protected function setArrowPosition() : void
      {
         var spr:Sprite = null;
         var point:Point = null;
         if(Boolean(this.m_arrow) && Boolean(m_displayObject))
         {
            spr = m_displayObject as Sprite;
            this.m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point = new Point(0,0);
               point.y = -1.4 * Math.min(m_displayObject.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (Math.min(m_displayObject.width,DEFAULT_ARROW_SIZE_X) - spr.getChildAt(0).width) * spr.scaleX / 2;
               if(point.x != this.m_arrow.x || point.y != this.m_arrow.y)
               {
                  this.m_arrow.y = point.y;
                  this.m_arrow.x = point.x;
               }
            }
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = this.m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      private function createArrowIndicator() : DisplayObject
      {
         var arrowIndicator:DisplayObject = null;
         var iconUrl:String = "";
         iconUrl = "assets/hud/FV_clock_100x100.png";
         var title:String = ZLocUtils.t("Dialogs","UnwitherClock_Arrow_Title");
         var text:String = ZLocUtils.t("Dialogs","UnwitherClock_Arrow_Days");
         var counterText:String = null;
         arrowIndicator = new ArrowIndicatorWindow(iconUrl,title,text,counterText);
         FarmStatsManager.count("unwither_clock","see_arrow");
         return arrowIndicator;
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(this.m_arrow) && Boolean(this.m_arrow.visible) && this.m_arrow.parent != null)
         {
            this.m_arrow.visible = false;
            this.m_arrow.parent.removeChild(this.m_arrow);
            this.m_arrow = null;
            conditionallyRedraw(true);
         }
      }
   }
}

import Transactions.TFarmTransaction;

class TBuyTime extends TFarmTransaction
{
   
   private var m_numRecharges:int = 0;
   
   public function TBuyTime(numRecharge:int = 0)
   {
      super();
      this.m_numRecharges = numRecharge;
   }
   
   override public function perform() : void
   {
      signedCall("UnwitherClockService.extendEnglandUnwitherClock",this.m_numRecharges);
   }
}
