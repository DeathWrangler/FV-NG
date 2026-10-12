package Display
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TIntegratedCrossGamePurgeReceived;
   import Transactions.TIntegratedCrossGameSendItem;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.TooltipController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   
   public class CrossPromoMailboxDialog extends FarmDynamicDialog implements ICellController
   {
      
      private static const ACTION_SEND:String = "send";
      
      private static const ACTION_RECEIVE:String = "receive";
      
      private static const SEND_LEFT_ARROW:String = "sendLeftArrow";
      
      private static const SEND_RIGHT_ARROW:String = "sendRightArrow";
      
      private static const RECEIVE_LEFT_ARROW:String = "receiveLeftArrow";
      
      private static const RECEIVE_RIGHT_ARROW:String = "receiveRightArrow";
      
      private static const SEND_TAB_BUTTON:String = "sendTabButton";
      
      private static const RECEIVE_TAB_BUTTON:String = "receiveTabButton";
      
      private static const ACTIVE_TAB_ASSET:String = "assets/dialogs/4d_elements/City_xPromo/xpromoCity_Button_Send.png";
      
      private static const DISABLED_TAB_ASSET:String = "assets/dialogs/4d_elements/City_xPromo/xpromoCity_Button_Send_dim.png";
      
      public static const RECEIVED_GIFTS:String = "receivedGifts";
      
      public static const LAST_SENT:String = "lastSent";
      
      private static const MAX_GRID_LENGTH:int = 8;
      
      public static const MAX_SEND_TIME:Number = Global.farmGameSettingsManager.getInt("crossGameGiftingDuration");
      
      protected var m_gameID:String = "";
      
      protected var m_sendItems:Array = new Array();
      
      protected var m_receivedItems:Array = new Array();
      
      protected var m_sendButtons:Array = new Array();
      
      protected var m_sendPageIndex:int = 0;
      
      protected var m_receivedPageIndex:int = 0;
      
      protected var m_isMaxSendPage:Boolean = false;
      
      protected var m_isMaxReceivedPage:Boolean = false;
      
      protected var m_currentTab:Boolean = true;
      
      protected var m_crossGameGifting:Object = new Object();
      
      protected var m_timeRemaining:Number = 0;
      
      protected var m_countDownClock:BaseWidgetController = null;
      
      protected var m_timeUpdater:Timer;
      
      protected var m_notInstalled:Boolean = false;
      
      public function CrossPromoMailboxDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var receivedItem:FarmItem = null;
         var controller:BaseWidgetController = null;
         var locked:Boolean = false;
         var hasReceived:Boolean = false;
         var newIndex:int = 0;
         var itemName:String = "";
         var style:BaseStyle = null;
         var cloneController:BaseWidgetController = null;
         if(this.m_currentTab)
         {
            newIndex = MAX_GRID_LENGTH * this.m_sendPageIndex + index;
            if(this.m_sendItems[newIndex]["requiredLevel"] > Global.player.level)
            {
               locked = true;
            }
            if(locked)
            {
               controller = newCell.getChildController("sendCellBG");
               if(controller != null)
               {
                  style = MT4DManager.getInstance().getStyle("XPromoInnerLockedBG");
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_STYLE,style);
               }
               controller = newCell.getChildController("sendLock");
               if(controller != null)
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               }
            }
            controller = newCell.getChildController("sendItemImage");
            if(controller != null)
            {
               controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,this.m_sendItems[newIndex]["icon"]);
            }
            controller = newCell.getChildController("sendTooltip");
            if(controller != null)
            {
               cloneController = controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW);
               cloneController = cloneController.clone();
               controller.setAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW,cloneController.getView());
               controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).index = newIndex;
               controller.addEventListener(WidgetControllerEvent.ADD_CHILD_VIEW,this.setupToolTip);
            }
            controller = newCell.getChildController("sendItemName");
            if(controller != null)
            {
               itemName = ZLocUtils.t("Dialogs",this.m_sendItems[newIndex]["name"] + "_friendlyName");
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,itemName);
            }
            controller = newCell.getChildController("sendItemButton");
            if(controller != null)
            {
               controller.setAttribute(ButtonController.ATTRIBUTE_TEXT,"Send");
               controller.index = newIndex;
               if(locked)
               {
                  controller.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
               }
               else
               {
                  controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onSendButtonPress);
               }
               this.m_sendButtons.push(controller);
            }
         }
         else
         {
            newIndex = MAX_GRID_LENGTH * this.m_receivedPageIndex + index;
            if(!this.m_crossGameGifting.hasOwnProperty("playerLevel") || this.m_receivedItems[newIndex]["requiredLevel"] > this.m_crossGameGifting["playerLevel"])
            {
               locked = true;
            }
            if(this.m_crossGameGifting != null && this.m_crossGameGifting.hasOwnProperty(RECEIVED_GIFTS))
            {
               if(this.m_crossGameGifting[RECEIVED_GIFTS] != null && Boolean(this.m_crossGameGifting[RECEIVED_GIFTS].hasOwnProperty(this.m_receivedItems[newIndex]["name"])))
               {
                  hasReceived = true;
               }
            }
            if(locked || !hasReceived)
            {
               controller = newCell.getChildController("receivedCellBG");
               if(controller != null)
               {
                  style = MT4DManager.getInstance().getStyle("XPromoInnerLockedBG");
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_STYLE,style);
               }
               controller = newCell.getChildController("receivedLock");
               if(controller != null && locked)
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               }
            }
            controller = newCell.getChildController("receivedItemImage");
            receivedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_receivedItems[newIndex]["name"]);
            if(controller != null)
            {
               controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,receivedItem.icon);
            }
            controller = newCell.getChildController("receivedItemQuantity");
            if(controller != null)
            {
               if(locked || !hasReceived)
               {
                  controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,"x0");
               }
               else if(this.m_crossGameGifting[RECEIVED_GIFTS] != null && Boolean(this.m_crossGameGifting[RECEIVED_GIFTS].hasOwnProperty(this.m_receivedItems[newIndex]["name"])))
               {
                  controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,"x" + this.m_crossGameGifting[RECEIVED_GIFTS][this.m_receivedItems[newIndex]["name"]].toString());
               }
            }
            controller = newCell.getChildController("receivedItemName");
            if(controller != null)
            {
               itemName = ZLocUtils.tk_pk_asTitle(receivedItem.friendlyName);
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,itemName);
            }
         }
         return newCell;
      }
      
      override public function setup() : void
      {
         super.setup();
         this.m_gameID = CrossPromoConstants.CITY_GAME_ID;
         this.m_sendItems = Global.farmGameSettingsManager.getIntegratedCrossGameData(this.m_gameID,ACTION_SEND);
         this.m_receivedItems = Global.farmGameSettingsManager.getIntegratedCrossGameData(this.m_gameID,ACTION_RECEIVE);
         this.m_crossGameGifting = Global.player.getCrossGameGiftingStateData(this.m_gameID);
         this.m_countDownClock = this.getShortcutController("xPromoSendGiftClock");
         if(this.m_crossGameGifting["playerLevel"] <= 0 || !this.m_crossGameGifting.hasOwnProperty("playerLevel"))
         {
            this.m_notInstalled = true;
         }
         this.setupItems();
         this.setupBalloon();
         this.setupTabs();
         this.setupArrows();
         this.setupGoToGame();
      }
      
      override public function destroy() : void
      {
         if(this.m_timeUpdater != null)
         {
            this.m_timeUpdater.removeEventListener(TimerEvent.TIMER,this.updateTimer);
         }
         super.destroy();
      }
      
      public function setupBalloon() : void
      {
         var timeLeft:Number = NaN;
         var view:BaseWidgetView = null;
         if(this.m_notInstalled)
         {
            this.toggleVisibleAndObstruct("BubbleText",true);
            this.toggleVisibleAndObstruct("countDownTimer",false);
            this.setShortcutAttribute("BubbleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","CityNotInstalledText"));
         }
         else if(this.canSendGift())
         {
            this.toggleVisibleAndObstruct("BubbleText",true);
            this.toggleVisibleAndObstruct("countDownTimer",false);
         }
         else if(this.m_timeRemaining != 0)
         {
            timeLeft = this.m_timeRemaining;
            this.m_timeUpdater = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND,timeLeft);
            this.m_timeUpdater.addEventListener(TimerEvent.TIMER,this.updateTimer);
            this.m_timeUpdater.start();
            this.toggleVisibleAndObstruct("BubbleText",false);
            this.toggleVisibleAndObstruct("countDownTimer",true);
            this.setTimers(timeLeft);
            this.disableButtons();
         }
      }
      
      public function setTimers(timeLeft:Number) : void
      {
         var hours:int = timeLeft / FarmGameUtil.NUM_SECS_IN_HOUR;
         timeLeft -= hours * FarmGameUtil.NUM_SECS_IN_HOUR;
         var mins:int = timeLeft / FarmGameUtil.NUM_SECS_IN_MINUTE;
         timeLeft -= mins * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var secs:int = timeLeft;
         this.setupCountDownClock(hours,mins,secs);
      }
      
      public function updateTimer(event:TimerEvent) : void
      {
         var timeLeft:Number = MAX_SEND_TIME - (GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_crossGameGifting[LAST_SENT]);
         if(timeLeft <= 0)
         {
            this.setupBalloon();
         }
         else
         {
            this.setTimers(timeLeft);
         }
      }
      
      private function canSendGift() : Boolean
      {
         var serverTime:Number = NaN;
         var canSend:Boolean = false;
         if(this.m_crossGameGifting[LAST_SENT] != null)
         {
            serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(serverTime - this.m_crossGameGifting[LAST_SENT] > MAX_SEND_TIME)
            {
               canSend = true;
            }
            else
            {
               this.m_timeRemaining = MAX_SEND_TIME - (serverTime - this.m_crossGameGifting[LAST_SENT]);
            }
         }
         else
         {
            canSend = true;
         }
         return canSend;
      }
      
      private function setupItems() : void
      {
         var cellCount:int = 0;
         if(this.m_sendItems.length > 0 && this.m_currentTab)
         {
            cellCount = 0;
            if(this.m_sendItems.length > MAX_GRID_LENGTH * (this.m_sendPageIndex + 1))
            {
               cellCount = MAX_GRID_LENGTH;
               this.m_isMaxSendPage = false;
            }
            else
            {
               cellCount = MAX_GRID_LENGTH - (MAX_GRID_LENGTH * (this.m_sendPageIndex + 1) - this.m_sendItems.length);
               this.m_isMaxSendPage = true;
            }
            this.setShortcutAttribute("sendCell",CellController.ATTRIBUTE_CREATE,this);
            this.setShortcutAttribute("sendCell",CellController.ATTRIBUTE_CELL_COUNT,cellCount);
         }
         if(this.m_receivedItems.length > 0 && !this.m_currentTab)
         {
            cellCount = 0;
            if(this.m_receivedItems.length > MAX_GRID_LENGTH * (this.m_receivedPageIndex + 1))
            {
               cellCount = MAX_GRID_LENGTH;
               this.m_isMaxReceivedPage = false;
            }
            else
            {
               cellCount = MAX_GRID_LENGTH - (MAX_GRID_LENGTH * (this.m_receivedPageIndex + 1) - this.m_receivedItems.length);
               this.m_isMaxReceivedPage = true;
            }
            this.setShortcutAttribute("receiveCell",CellController.ATTRIBUTE_CREATE,this);
            this.setShortcutAttribute("receiveCell",CellController.ATTRIBUTE_CELL_COUNT,cellCount);
         }
         if(this.m_notInstalled)
         {
            this.disableButtons();
         }
         analyzeDialog();
      }
      
      private function setupTabs() : void
      {
         this.setShortcutAttribute(SEND_TAB_BUTTON,ButtonController.ATTRIBUTE_TEXT,ACTION_SEND);
         this.setShortcutAttribute(SEND_TAB_BUTTON,ButtonController.ATTRIBUTE_DISABLED,true);
         this.setShortcutListener(SEND_TAB_BUTTON,WidgetControllerEvent.BUTTON_PRESSED,this.onSendTabPress);
         this.setShortcutAttribute(RECEIVE_TAB_BUTTON,ButtonController.ATTRIBUTE_TEXT,ACTION_RECEIVE);
         this.setShortcutListener(RECEIVE_TAB_BUTTON,WidgetControllerEvent.BUTTON_PRESSED,this.onReceiveTabPress);
      }
      
      private function setupArrows() : void
      {
         if(this.m_sendPageIndex == 0)
         {
            this.setShortcutAttribute(SEND_LEFT_ARROW,ButtonController.ATTRIBUTE_DISABLED,true);
         }
         else
         {
            this.setShortcutAttribute(SEND_LEFT_ARROW,ButtonController.ATTRIBUTE_DISABLED,false);
            this.setShortcutListener(SEND_LEFT_ARROW,WidgetControllerEvent.BUTTON_PRESSED,this.onSendLeftArrowPress);
         }
         if(this.m_sendItems.length <= MAX_GRID_LENGTH || this.m_isMaxSendPage == true)
         {
            this.setShortcutAttribute(SEND_RIGHT_ARROW,ButtonController.ATTRIBUTE_DISABLED,true);
         }
         else
         {
            this.setShortcutAttribute(SEND_RIGHT_ARROW,ButtonController.ATTRIBUTE_DISABLED,false);
            this.setShortcutListener(SEND_RIGHT_ARROW,WidgetControllerEvent.BUTTON_PRESSED,this.onSendRightArrowPress);
         }
         if(this.m_receivedPageIndex == 0)
         {
            this.setShortcutAttribute(RECEIVE_LEFT_ARROW,ButtonController.ATTRIBUTE_DISABLED,true);
         }
         else
         {
            this.setShortcutAttribute(RECEIVE_LEFT_ARROW,ButtonController.ATTRIBUTE_DISABLED,false);
            this.setShortcutListener(RECEIVE_LEFT_ARROW,WidgetControllerEvent.BUTTON_PRESSED,this.onReceivedLeftArrowPress);
         }
         if(this.m_receivedItems.length <= MAX_GRID_LENGTH || this.m_isMaxReceivedPage == true)
         {
            this.setShortcutAttribute(RECEIVE_RIGHT_ARROW,ButtonController.ATTRIBUTE_DISABLED,true);
         }
         else
         {
            this.setShortcutAttribute(RECEIVE_RIGHT_ARROW,ButtonController.ATTRIBUTE_DISABLED,false);
            this.setShortcutListener(RECEIVE_RIGHT_ARROW,WidgetControllerEvent.BUTTON_PRESSED,this.onReceivedRightArrowPress);
         }
      }
      
      private function onSendLeftArrowPress(event:WidgetControllerEvent) : void
      {
         --this.m_sendPageIndex;
         this.setupItems();
         this.setupBalloon();
         this.setupArrows();
      }
      
      private function onSendRightArrowPress(event:WidgetControllerEvent) : void
      {
         ++this.m_sendPageIndex;
         this.setupItems();
         this.setupBalloon();
         this.setupArrows();
      }
      
      private function onReceivedLeftArrowPress(event:WidgetControllerEvent) : void
      {
         --this.m_receivedPageIndex;
         this.setupItems();
         this.setupBalloon();
         this.setupArrows();
      }
      
      private function onReceivedRightArrowPress(event:WidgetControllerEvent) : void
      {
         ++this.m_receivedPageIndex;
         this.setupItems();
         this.setupBalloon();
         this.setupArrows();
      }
      
      private function onSendButtonPress(event:WidgetControllerEvent) : void
      {
         var sendIndex:int = event.getController().index;
         TransactionManager.addTransaction(new TIntegratedCrossGameSendItem(this.m_gameID,this.m_sendItems[sendIndex]["name"],this),true);
         this.m_crossGameGifting[LAST_SENT] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         this.m_timeRemaining = MAX_SEND_TIME;
         this.setupBalloon();
         this.disableButtons();
      }
      
      public function disableButtons() : void
      {
         for(var index:int = 0; index < this.m_sendButtons.length; index++)
         {
            (this.m_sendButtons[index] as BaseWidgetController).setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
         }
      }
      
      private function onSendTabPress(event:WidgetControllerEvent) : void
      {
         this.m_currentTab = true;
         event.getController().setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
         event.getController().getChildController("sendTabImage").setAttribute(ImageController.ATTRIBUTE_SOURCE,ACTIVE_TAB_ASSET);
         this.setShortcutAttribute("receiveTabImage",ImageController.ATTRIBUTE_SOURCE,DISABLED_TAB_ASSET);
         this.setShortcutAttribute(RECEIVE_TAB_BUTTON,ButtonController.ATTRIBUTE_DISABLED,false);
         this.toggleVisibleAndObstruct("sendPageView",true);
         this.toggleVisibleAndObstruct("receivePageView",false);
         this.setupItems();
         this.setupBalloon();
      }
      
      private function onReceiveTabPress(event:WidgetControllerEvent) : void
      {
         this.m_currentTab = false;
         event.getController().setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
         event.getController().getChildController("receiveTabImage").setAttribute(ImageController.ATTRIBUTE_SOURCE,ACTIVE_TAB_ASSET);
         this.setShortcutAttribute("sendTabImage",ImageController.ATTRIBUTE_SOURCE,DISABLED_TAB_ASSET);
         this.setShortcutAttribute(SEND_TAB_BUTTON,ButtonController.ATTRIBUTE_DISABLED,false);
         this.toggleVisibleAndObstruct("sendPageView",false);
         this.toggleVisibleAndObstruct("receivePageView",true);
         this.setupItems();
         TransactionManager.addTransaction(new TIntegratedCrossGamePurgeReceived(this.m_gameID));
      }
      
      private function setupCountDownClock(hours:int, mins:int, secs:int) : void
      {
         var countDownGroup:BaseWidgetController = null;
         if(this.m_countDownClock != null)
         {
            countDownGroup = null;
            countDownGroup = this.m_countDownClock.getChildController("hour");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(hours,ZLocUtils.t("Dialogs","Hours").toLocaleUpperCase(),countDownGroup);
            }
            countDownGroup = this.m_countDownClock.getChildController("min");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(mins,ZLocUtils.t("Dialogs","Mins").toLocaleUpperCase(),countDownGroup);
            }
            countDownGroup = this.m_countDownClock.getChildController("sec");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(secs,ZLocUtils.t("Dialogs","Secs").toLocaleUpperCase(),countDownGroup);
            }
         }
      }
      
      private function setupCountDownGroup(time:int, label:String, group:BaseWidgetController) : void
      {
         var timeStr:String = time.toString();
         var digit1:String = null;
         var digit2:String = null;
         if(timeStr.length < 2)
         {
            digit1 = "0";
            digit2 = timeStr.charAt(0);
         }
         else
         {
            digit1 = timeStr.charAt(0);
            digit2 = timeStr.charAt(1);
         }
         group.getChildController("body.leftText.text").setAttribute(TextFieldView.ATTRIBUTE_TEXT,digit1);
         group.getChildController("body.rightText.text").setAttribute(TextFieldView.ATTRIBUTE_TEXT,digit2);
         group.getChildController("magnitudeText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,label);
      }
      
      private function setupGoToGame() : void
      {
         this.setShortcutListener("GoToCity",WidgetControllerEvent.BUTTON_PRESSED,this.onClickGoToGame);
      }
      
      private function onClickGoToGame(event:WidgetControllerEvent) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open","https://apps.facebook.com/cityville/tracks.php?src=xpromo&aff=farmville&crt=xgifting");
         }
         this.destroy();
      }
      
      private function setupToolTip(event:WidgetControllerEvent) : void
      {
         var text:String = null;
         var locked:Boolean = false;
         if(event.getController().getName() == "XPromoTooltipView")
         {
            text = "";
            locked = false;
            if(this.m_sendItems[event.getController().index]["requiredLevel"] > Global.player.level)
            {
               locked = true;
            }
            if(locked)
            {
               text = ZLocUtils.t("Dialogs","XPromoUnlockAtLevel",{"levelNum":this.m_sendItems[event.getController().index]["requiredLevel"]});
               event.getController().findChildControllerByName("descText").setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               event.getController().findChildControllerByName("descText").setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            }
            else
            {
               text = ZLocUtils.t("Dialogs",this.m_sendItems[event.getController().index]["name"] + "_title");
               event.getController().findChildControllerByName("descText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",this.m_sendItems[event.getController().index]["name"] + "_description"));
            }
            event.getController().findChildControllerByName("headerText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,text);
         }
      }
   }
}

