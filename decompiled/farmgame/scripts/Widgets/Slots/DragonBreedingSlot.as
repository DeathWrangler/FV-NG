package Widgets.Slots
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.DragonBreedingLairFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.DragonBreedingWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DragonBreedingSlot extends ZwSlotFrame
   {
      
      public static const STATE_LOCKED:int = -1;
      
      public static const STATE_READY:int = 0;
      
      public static const STATE_SELECT:int = 1;
      
      public static const STATE_BREEDING:int = 2;
      
      public static const STATE_MARKET_BUY:int = 3;
      
      public static const STATE_VISIT:int = 4;
      
      private static const ICON_FADE:Number = 0.7;
      
      private static const ICON_OPAQUE:Number = 1;
      
      private static const MOUSE_OUT_STATE:int = 1;
      
      private static const MOUSE_OVER_STATE:int = 2;
      
      private const MARKET_BTN:String = "market_bt";
      
      private const BREEDING_MC:String = "breeding_mc";
      
      private const BREEDING_TF:String = "breeding_tf";
      
      private const FRIEND_ICON:String = "friendicon_mc";
      
      private const FRIEND_ICON_TIMER_TF:String = "timer_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const ITEM_TITLE_TF:String = "itemTitle_tf";
      
      private const ITEM_AMOUNT_TF:String = "itemAmount_tf";
      
      private const UNLOCK_TF:String = "unlock_tf";
      
      private const LOCK_MC:String = "lock_mc";
      
      private const SELECT_MC:String = "select_mc";
      
      private var m_featureName:String = "";
      
      private var m_window:DragonBreedingWindow;
      
      private var m_frame:DragonBreedingLairFrame;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_lock:MovieClip;
      
      private var m_dragonIcon:ResourcePreviewFrame;
      
      private var m_breedingStatus:MovieClip;
      
      private var m_breedingTimerText:ZwTextField;
      
      private var m_visitingStatus:MovieClip;
      
      private var m_visitingDragonTimerText:ZwTextField;
      
      private var m_dragonNameTxt:ZwTextField;
      
      private var m_dragonQtyTxt:ZwTextField;
      
      private var m_unlockTxt:ZwTextField;
      
      private var m_selectMc:MovieClip;
      
      private var m_isSelected:Boolean;
      
      private var m_itemData:Object;
      
      private var m_itemCode:String = "";
      
      private var m_currentState:int;
      
      private var m_breedSession:DragonBreedingSession;
      
      private var m_breedTimer:Timer;
      
      private var m_visitingDragonTimer:Timer;
      
      private var m_objectPreviewFrame:ResourcePreviewFrame;
      
      private var m_itemCount:int = 0;
      
      private var m_unlockTooltipTxt:String;
      
      private var m_marketTooltip:FarmTextTooltip;
      
      public function DragonBreedingSlot(element:DisplayObject, featureName:String, window:DragonBreedingWindow, frame:DragonBreedingLairFrame)
      {
         var unlockCost:int = 0;
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
         this.m_frame = frame;
         if(m_element.hasOwnProperty(this.MARKET_BTN))
         {
            unlockCost = DragonBreedingManager.getInstance(this.m_featureName).getDragonUnlockCost();
            addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element[this.MARKET_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"PresentSendConfirmButton"),unlockCost.toString(),this.onBuyClick),false);
         }
         if(m_element.hasOwnProperty(this.BREEDING_MC))
         {
            this.m_breedingStatus = m_element[this.BREEDING_MC] as MovieClip;
            if(Boolean(this.m_breedingStatus) && this.m_breedingStatus.hasOwnProperty(this.BREEDING_TF))
            {
               addWidget(this.m_breedingTimerText = new ZwTextField(this.m_breedingStatus[this.BREEDING_TF],""),false);
            }
         }
         if(m_element.hasOwnProperty(this.FRIEND_ICON))
         {
            this.m_visitingStatus = m_element[this.FRIEND_ICON] as MovieClip;
            if(Boolean(this.m_visitingStatus) && this.m_visitingStatus.hasOwnProperty(this.FRIEND_ICON_TIMER_TF))
            {
               addWidget(this.m_visitingDragonTimerText = new ZwTextField(this.m_visitingStatus[this.FRIEND_ICON_TIMER_TF],""));
            }
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_dragonIcon = new ResourcePreviewFrame(m_element[this.ICON_MC]));
         }
         if(m_element.hasOwnProperty(this.ITEM_TITLE_TF))
         {
            addWidget(this.m_dragonNameTxt = new ZwTextField(m_element[this.ITEM_TITLE_TF],""),true);
         }
         if(m_element.hasOwnProperty(this.ITEM_AMOUNT_TF))
         {
            addWidget(this.m_dragonQtyTxt = new ZwTextField(m_element[this.ITEM_AMOUNT_TF],""));
         }
         if(m_element.hasOwnProperty(this.UNLOCK_TF))
         {
            addWidget(this.m_unlockTxt = new ZwTextField(m_element[this.UNLOCK_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_UnlockText",{"level":"5"})));
         }
         if(m_element.hasOwnProperty(this.LOCK_MC))
         {
            this.m_lock = m_element[this.LOCK_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.SELECT_MC))
         {
            this.m_selectMc = m_element[this.SELECT_MC] as MovieClip;
         }
         m_element.mouseEnabled = true;
         this.registerEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         this.m_isSelected = false;
         this.m_currentState = STATE_LOCKED;
         this.toggleSelect();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         m_element.gotoAndStop(MOUSE_OUT_STATE);
         this.detachTooltip();
         this.m_itemData = data;
         if(this.m_itemData.itemData.hasOwnProperty("itemCount"))
         {
            this.m_itemCount = this.m_itemData.itemData.itemCount;
         }
         if(Boolean(this.m_itemData) && this.m_itemData.hasOwnProperty("itemCode"))
         {
            this.m_itemCode = this.m_itemData.itemCode;
         }
         this.m_currentState = STATE_LOCKED;
         this.unregisterEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onDragonMouseRollOver);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onDragonMouseRollOut);
         var levelToUnlock:String = DragonBreedingConfigManager.getInstance(this.m_featureName).getLevelByRewardItemCode(this.m_itemCode).toString();
         this.m_unlockTxt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_UnlockText",{"level":levelToUnlock});
         this.m_unlockTooltipTxt = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_UnlockTooltipText",{"level":levelToUnlock});
         this.renderItem();
         this.refreshSlotData();
         this.setDragonCount();
      }
      
      private function refreshBreedingTimer() : void
      {
         var timeRemaining:Number = NaN;
         if(this.m_breedSession)
         {
            if(this.m_breedSession.breedingTimeRemaining > 0)
            {
               timeRemaining = this.m_breedSession.breedingTimeRemaining;
               this.m_breedingTimerText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_breedTimerTxt",{"time":HUD.getformattedTimeLeft(timeRemaining)});
               this.m_breedingTimerText.visible = true;
               if(this.m_breedTimer != null)
               {
                  this.m_breedTimer.stop();
               }
               if(this.m_breedTimer == null)
               {
                  this.m_breedTimer = new Timer(1000);
                  this.m_breedTimer.addEventListener(TimerEvent.TIMER,this.onBreedTimer,false,0,true);
               }
               if(!this.m_breedTimer.running)
               {
                  this.m_breedTimer.start();
               }
            }
            else
            {
               if(this.m_breedTimer)
               {
                  this.m_breedTimer.stop();
                  this.m_breedTimer.removeEventListener(TimerEvent.TIMER,this.onBreedTimer);
                  this.m_breedTimer = null;
               }
               this.setEggReadyState();
            }
         }
         else
         {
            this.setEggReadyState();
         }
      }
      
      private function onBreedTimer(e:TimerEvent) : void
      {
         this.refreshBreedingTimer();
      }
      
      private function isInBreeding() : Boolean
      {
         var result:Boolean = false;
         var breedingItemCount:int = DragonBreedingManager.getInstance(this.m_featureName).getItemBreedingCountByItemCode(this.m_itemCode);
         return breedingItemCount > 0 ? true : false;
      }
      
      private function setSelectedState() : void
      {
         this.m_breedingStatus.visible = false;
         this.m_lock.visible = false;
         this.m_visitingStatus.visible = false;
         this.m_buyButton.visible = false;
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = false;
         }
         this.enabled = true;
         this.toggleSelect(true);
         this.m_isSelected = true;
         this.registerEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         if(m_element.icon_mc)
         {
            m_element.icon_mc.alpha = ICON_OPAQUE;
            m_element.icon_mc.visible = true;
         }
         if(!DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.enableVisitingDragon();
         }
      }
      
      private function setReadyState() : void
      {
         this.m_breedingStatus.visible = false;
         this.m_lock.visible = false;
         this.m_visitingStatus.visible = false;
         this.m_buyButton.visible = false;
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = false;
         }
         this.enabled = true;
         this.m_isSelected = false;
         m_element.useHandCursor = true;
         m_element.buttonMode = true;
         this.registerEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         this.toggleSelect();
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onDragonMouseRollOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onDragonMouseRollOut);
         if(m_element.icon_mc)
         {
            m_element.icon_mc.alpha = ICON_OPAQUE;
            m_element.icon_mc.visible = true;
         }
         if(!DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.enableVisitingDragon();
         }
      }
      
      private function setBreedingState() : void
      {
         this.m_breedingStatus.visible = true;
         if(this.m_lock)
         {
            this.m_lock.visible = false;
         }
         if(this.m_visitingStatus)
         {
            this.m_visitingStatus.visible = false;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = false;
         }
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = false;
         }
         this.enabled = false;
         this.m_isSelected = false;
         if(m_element.icon_mc)
         {
            m_element.icon_mc.visible = false;
         }
         this.toggleSelect();
         this.m_breedSession = DragonBreedingManager.getInstance(this.m_featureName).getBreedSessionByItemCode(this.m_itemCode);
         this.refreshBreedingTimer();
         if(!DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.enableVisitingDragon();
         }
      }
      
      private function setEggReadyState() : void
      {
         this.m_breedingStatus.visible = true;
         if(this.m_lock)
         {
            this.m_lock.visible = false;
         }
         if(this.m_visitingStatus)
         {
            this.m_visitingStatus.visible = false;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = false;
         }
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = false;
         }
         this.enabled = false;
         this.m_isSelected = false;
         if(m_element.icon_mc)
         {
            m_element.icon_mc.visible = false;
         }
         this.toggleSelect();
         this.m_breedingTimerText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_eggready_txt");
         this.m_breedingTimerText.visible = true;
         if(!DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.enableVisitingDragon();
         }
      }
      
      private function setMarketBuyState() : void
      {
         var msg:String = null;
         this.m_breedingStatus.visible = false;
         this.m_lock.visible = true;
         this.m_visitingStatus.visible = false;
         this.m_buyButton.visible = true;
         this.m_buyButton.enabled = true;
         if(DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode() && !this.m_window.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_10))
         {
            this.m_buyButton.enabled = false;
         }
         if(this.m_unlockTxt)
         {
            this.m_unlockTxt.visible = false;
         }
         this.enabled = true;
         this.m_isSelected = false;
         if(Boolean(this.m_buyButton.enabled == true) && Boolean(this.m_unlockTxt) && !DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.m_unlockTxt.visible = false;
            msg = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MarketTooltipText");
            this.m_marketTooltip = new FarmTextTooltip(msg);
            this.attachTooltip(this.m_marketTooltip);
         }
         this.unregisterEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         this.toggleSelect();
         if(m_element.icon_mc)
         {
            m_element.icon_mc.alpha = ICON_FADE;
            m_element.icon_mc.visible = true;
         }
      }
      
      private function setLockState() : void
      {
         this.m_breedingStatus.visible = false;
         this.m_lock.visible = true;
         this.m_visitingStatus.visible = false;
         this.m_buyButton.visible = false;
         if(Boolean(this.m_unlockTxt) && !DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.m_unlockTxt.visible = false;
            this.attachTooltip(new FarmTextTooltip(this.m_unlockTooltipTxt));
         }
         this.m_isSelected = false;
         this.toggleSelect();
         if(m_element.icon_mc)
         {
            m_element.icon_mc.alpha = ICON_FADE;
            m_element.icon_mc.visible = true;
         }
         if(!DragonBreedingManager.getInstance(this.m_featureName).isTutorialMode())
         {
            this.enableVisitingDragon();
         }
      }
      
      private function renderItem() : void
      {
         var item:FarmItem = null;
         var exportedName:String = null;
         if(Boolean(this.m_itemData) && this.m_itemData.hasOwnProperty("itemCode"))
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemData.itemCode);
            if(item)
            {
               if(m_element.hasOwnProperty("icon_mc"))
               {
                  this.m_objectPreviewFrame = getWidget(m_element.icon_mc) as ResourcePreviewFrame;
                  if(this.m_objectPreviewFrame)
                  {
                     removeWidget(this.m_objectPreviewFrame);
                  }
                  exportedName = item.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
                  this.m_objectPreviewFrame = new ResourcePreviewFrame(m_element.icon_mc,item.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportedName);
                  addWidget(this.m_objectPreviewFrame,true);
               }
               if(this.m_dragonNameTxt)
               {
                  this.m_dragonNameTxt.text = item.friendlyTitle;
                  this.m_dragonNameTxt.visible = true;
               }
            }
         }
      }
      
      private function onSelectDragonHandler(eve:MouseEvent) : void
      {
         this.unregisterEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         if(this.m_currentState == STATE_READY)
         {
            this.m_frame.selectedSlot = this;
            this.m_currentState = STATE_SELECT;
         }
         else if(this.m_currentState == STATE_SELECT)
         {
            this.m_frame.selectedSlot = null;
            this.m_currentState = STATE_READY;
         }
         if(this.m_window.isInTutorial())
         {
            if(this.m_window.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_1))
            {
               this.m_window.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_2);
            }
            if(this.m_window.selectedMaleDragonId != "" && this.m_window.selectedFemaleDragonId != "")
            {
               if(this.m_window.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_2))
               {
                  this.m_window.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_3);
               }
            }
         }
      }
      
      private function onDragonMouseRollOver(eve:MouseEvent) : void
      {
         m_element.gotoAndStop(MOUSE_OVER_STATE);
      }
      
      private function onDragonMouseRollOut(eve:MouseEvent) : void
      {
         m_element.gotoAndStop(MOUSE_OUT_STATE);
      }
      
      private function onBuyClick(event:Event) : void
      {
         var itemName:String = null;
         if(this.m_marketTooltip)
         {
            this.m_marketTooltip.release();
         }
         if(DragonBreedingManager.getInstance(this.m_featureName).onBuyDragon())
         {
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_itemData.itemCode);
            DragonBreedingManager.getInstance(this.m_featureName).showInMarket([itemName]);
            this.m_window.close();
         }
      }
      
      private function refreshSlotData() : void
      {
         var actualItemCount:int = 0;
         var isMarketItem:Boolean = false;
         var breedingItemCount:int = 0;
         if(this.m_breedTimer != null)
         {
            this.m_breedTimer.stop();
         }
         if(this.m_itemData.hasOwnProperty("itemData"))
         {
            actualItemCount = 0;
            if(this.m_itemData.itemData.hasOwnProperty("itemCount"))
            {
               actualItemCount = int(this.m_itemData.itemData.itemCount);
            }
            if(this.m_itemData.itemData.hasOwnProperty("unlocked"))
            {
               this.m_currentState = this.m_itemData.itemData.unlocked ? STATE_READY : STATE_LOCKED;
            }
            if(this.m_itemData.itemData.hasOwnProperty("itemCount"))
            {
               if(Boolean(this.m_itemData.itemData.hasOwnProperty("isMarketItem")) && Boolean(this.m_itemData.itemData.isMarketItem))
               {
                  this.m_currentState = this.m_itemData.itemData.itemCount < 1 ? STATE_MARKET_BUY : STATE_READY;
               }
               else
               {
                  this.m_currentState = int(this.m_itemData.itemData.itemCount) > 0 ? STATE_READY : STATE_LOCKED;
               }
            }
            if(this.m_window.selectedMaleDragonId == this.m_itemData.itemCode)
            {
               this.m_currentState = STATE_SELECT;
            }
            if(this.m_window.selectedFemaleDragonId == this.m_itemData.itemCode)
            {
               this.m_currentState = STATE_SELECT;
            }
            if(this.m_currentState == STATE_LOCKED && DragonBreedingManager.getInstance(this.m_featureName).isValidVisitingDragonByItemCode(this.m_itemCode))
            {
               this.m_currentState = STATE_READY;
            }
            if(DragonBreedingManager.getInstance(this.m_featureName).isValidVisitingDragonByItemCode(this.m_itemCode))
            {
               actualItemCount += 1;
            }
            if(this.m_currentState != STATE_LOCKED)
            {
               isMarketItem = this.m_currentState == STATE_MARKET_BUY ? true : false;
               breedingItemCount = DragonBreedingManager.getInstance(this.m_featureName).getItemBreedingCountByItemCode(this.m_itemCode);
               if(actualItemCount > 0)
               {
                  this.m_itemCount = actualItemCount - breedingItemCount < 0 ? 0 : int(actualItemCount - breedingItemCount);
               }
               this.m_currentState = STATE_READY;
               if(this.m_itemCount < 1)
               {
                  this.m_currentState = isMarketItem ? STATE_MARKET_BUY : STATE_LOCKED;
               }
               if(this.isInBreeding())
               {
                  this.m_currentState = isMarketItem ? STATE_MARKET_BUY : STATE_READY;
                  if(this.m_itemCount < 1)
                  {
                     this.m_currentState = STATE_BREEDING;
                  }
               }
            }
         }
         switch(this.m_currentState)
         {
            case STATE_READY:
               this.setReadyState();
               break;
            case STATE_SELECT:
               this.setSelectedState();
               break;
            case STATE_BREEDING:
               this.setBreedingState();
               break;
            case STATE_MARKET_BUY:
               this.setMarketBuyState();
               break;
            case STATE_LOCKED:
            default:
               this.setLockState();
         }
      }
      
      private function setDragonCount() : void
      {
         if(this.m_itemCount > 0)
         {
            this.m_dragonQtyTxt.text = "x" + this.m_itemCount.toString();
            if(this.m_itemCount > 1)
            {
               this.m_dragonQtyTxt.visible = true;
            }
            else
            {
               this.m_dragonQtyTxt.visible = false;
            }
         }
      }
      
      private function toggleSelect(toggle:Boolean = false) : void
      {
         if(this.m_selectMc)
         {
            if(toggle)
            {
               this.m_selectMc.visible = true;
               this.m_selectMc.gotoAndPlay(1);
            }
            else
            {
               this.m_selectMc.visible = false;
               this.m_selectMc.gotoAndStop(1);
            }
         }
      }
      
      private function enableVisitingDragon() : void
      {
         var timeRemaining:Number = NaN;
         if(DragonBreedingManager.getInstance(this.m_featureName).isValidVisitingDragonByItemCode(this.m_itemCode))
         {
            this.m_visitingStatus.visible = true;
            timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getVistingDragonTimeRemainingByItemCode(this.m_itemCode);
            if(timeRemaining > 0)
            {
               this.m_visitingDragonTimerText.visible = true;
               this.m_visitingDragonTimerText.text = HUD.getformattedTimeLeft(timeRemaining);
               if(this.m_visitingDragonTimer != null)
               {
                  this.m_visitingDragonTimer.stop();
               }
               if(this.m_visitingDragonTimer == null)
               {
                  this.m_visitingDragonTimer = new Timer(1000);
                  this.m_visitingDragonTimer.addEventListener(TimerEvent.TIMER,this.onVisitingDragonTimer,false,0,true);
               }
               if(!this.m_visitingDragonTimer.running)
               {
                  this.m_visitingDragonTimer.start();
               }
            }
            else
            {
               DragonBreedingManager.getInstance(this.m_featureName).resetVisitingDragonByItemCode(this.m_itemCode);
               this.refreshSlotData();
            }
         }
         else
         {
            if(this.m_visitingStatus)
            {
               this.m_visitingStatus.visible = false;
               this.m_visitingDragonTimerText.visible = false;
               this.m_visitingDragonTimerText.text = "";
            }
            if(this.m_visitingDragonTimer)
            {
               this.m_visitingDragonTimer.stop();
               this.m_visitingDragonTimer.removeEventListener(TimerEvent.TIMER,this.onVisitingDragonTimer);
               this.m_visitingDragonTimer = null;
            }
         }
      }
      
      private function onVisitingDragonTimer(event:TimerEvent) : void
      {
         this.enableVisitingDragon();
      }
      
      public function deselect() : void
      {
         this.toggleSelect();
      }
      
      public function setEnabled(enable:Boolean, isTutorialMode:Boolean = false) : void
      {
         if(!enable)
         {
            if(Boolean(this.m_itemData) && this.m_itemData.itemData.isMarketItem == true)
            {
               this.setMarketBuyState();
            }
            else
            {
               this.setLockState();
            }
            this.unregisterEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
            this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onDragonMouseRollOver);
            this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onDragonMouseRollOut);
         }
         else if(!isTutorialMode)
         {
            this.setReadyState();
            this.registerEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
            this.registerEventListener(MouseEvent.MOUSE_OVER,this.onDragonMouseRollOver);
            this.registerEventListener(MouseEvent.MOUSE_OUT,this.onDragonMouseRollOut);
         }
         else
         {
            this.setLockState();
            this.m_lock.visible = false;
         }
      }
      
      public function setSelectState(enable:Boolean) : void
      {
         if(this.m_currentState == STATE_READY || this.m_currentState == STATE_SELECT)
         {
            if(enable)
            {
               this.setSelectedState();
               this.m_currentState = STATE_SELECT;
            }
            else
            {
               this.setReadyState();
               this.m_currentState = STATE_READY;
            }
         }
      }
      
      public function get itemCode() : String
      {
         var result:String = "";
         if(Boolean(this.m_itemData) && this.m_itemData.hasOwnProperty("itemCode"))
         {
            result = this.m_itemData.itemCode;
         }
         return result;
      }
      
      public function get isSlotSelected() : Boolean
      {
         return this.m_isSelected;
      }
      
      override public function release() : void
      {
         if(this.m_breedTimer)
         {
            this.m_breedTimer.removeEventListener(TimerEvent.TIMER,this.onBreedTimer);
            this.m_breedTimer = null;
         }
         this.detachTooltip();
         this.unregisterEventListener(MouseEvent.CLICK,this.onSelectDragonHandler);
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onDragonMouseRollOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onDragonMouseRollOut);
         this.m_itemData = null;
         this.m_itemCode = null;
         this.m_selectMc = null;
         this.m_breedingStatus = null;
         this.m_breedingTimerText = null;
         this.m_breedSession = null;
         this.m_buyButton = null;
         this.m_dragonIcon = null;
         this.m_dragonNameTxt = null;
         this.m_dragonQtyTxt = null;
         this.m_frame = null;
         this.m_lock = null;
         this.m_selectMc = null;
         this.m_unlockTxt = null;
         this.m_visitingDragonTimerText = null;
         this.m_visitingStatus = null;
         super.release();
      }
   }
}

