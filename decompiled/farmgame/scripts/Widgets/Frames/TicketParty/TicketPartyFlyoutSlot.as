package Widgets.Frames.TicketParty
{
   import Classes.util.DisplayObjectUtils;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TicketPartyFlyoutSlot extends ZwFrame
   {
      
      protected static const FRAMELABEL_CLOSED:String = "CLOSED";
      
      protected static const FRAMELABEL_OPENING:String = "START_EXPAND";
      
      protected static const FRAMELABEL_CLOSING:String = "START_CONTRACT";
      
      protected static const FRAMELABEL_REFRESHUI:String = "REFRESH_UI";
      
      protected static const FLYOUTSTATE_NOACTION:Number = 0;
      
      protected static const FLYOUTSTATE_OPENED:Number = 1;
      
      protected static const FLYOUTSTATE_OPENING:Number = 2;
      
      protected static const FLYOUTSTATE_CLOSED:Number = 3;
      
      protected static const FLYOUTSTATE_CLOSING:Number = 4;
      
      protected static const FLYOUT_FORCE_CLOSE_TIME:Number = 3000;
      
      protected static const ICON_SIZE:int = 65;
      
      protected var m_itemName:String = "";
      
      protected var m_locked:Boolean = true;
      
      protected var m_redeemBtn:FarmAnimatedButton = null;
      
      protected var m_buyBtn:FarmAnimatedButton = null;
      
      protected var m_unlockBtn:FarmAnimatedButton = null;
      
      protected var m_unlockTf:ZwTextField = null;
      
      protected var m_allToggleFields:Array;
      
      protected var m_unlockedOpenFields:Array;
      
      protected var m_lockedOpenFields:Array;
      
      protected var m_expandMc:MovieClip = null;
      
      protected var m_callbacks:Object = null;
      
      protected var m_frameLabels:Object;
      
      protected var m_currentFlyoutState:Number = 3;
      
      protected var m_futureFlyoutState:Number = 0;
      
      protected var m_redeemItemSeenFlag:String = "";
      
      protected var m_ticketsToUnlock:Number = 0;
      
      public function TicketPartyFlyoutSlot(element:DisplayObject, itemName:String, ticketCost:Number, buyCost:Number, unlockCost:Number, iconURL:String, itemFriendlyName:String, redeemItemSeenFlag:String, locked:Boolean, callbacks:Object)
      {
         var frameLabel:FrameLabel = null;
         this.m_allToggleFields = new Array();
         this.m_unlockedOpenFields = new Array();
         this.m_lockedOpenFields = new Array();
         this.m_frameLabels = {};
         super(element);
         this.m_itemName = itemName;
         this.m_callbacks = callbacks;
         this.m_locked = locked;
         this.m_redeemItemSeenFlag = redeemItemSeenFlag;
         this.m_ticketsToUnlock = ticketCost;
         this.m_lockedOpenFields.push(addWidget(new ZwTextField(m_element.exp_itemname_tf,ZLocUtils.tk_pk_asTitle(itemFriendlyName))) as ZwTextField);
         this.m_unlockedOpenFields.push(addWidget(new ZwTextField(m_element.exp_unlockeditemname_tf,ZLocUtils.tk_pk_asTitle(itemFriendlyName))) as ZwTextField);
         var icon:FarmIcon = addWidget(new FarmIcon(m_element.item_mc,iconURL)) as FarmIcon;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(new ZwTextField(m_element.redeemitem_bt.redeem_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_redeem")));
         this.m_redeemBtn = addWidget(new FarmAnimatedButton(m_element.redeemitem_bt,this.redeemButtonCallback)) as FarmAnimatedButton;
         addWidget(new ZwTextField(m_element.buyitem_bt.buyfor_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_buyfor",{"cost":buyCost.toString()})));
         this.m_buyBtn = addWidget(new FarmAnimatedButton(m_element.buyitem_bt,this.buyButtonCallback)) as FarmAnimatedButton;
         this.m_unlockTf = addWidget(new ZwTextField(m_element.unlockLevel_bt.unlockfor_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_unlock",{"cost":unlockCost.toString()}))) as ZwTextField;
         this.m_unlockBtn = addWidget(new FarmAnimatedButton(m_element.unlockLevel_bt,this.unlockButtonCallback)) as FarmAnimatedButton;
         this.m_lockedOpenFields.push(addWidget(new ZwTextField(m_element.exp_unlockat_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_unlockAt"))) as ZwTextField);
         this.m_lockedOpenFields.push(addWidget(new ZwTextField(m_element.exp_cost_tf,ticketCost.toString())) as ZwTextField);
         this.m_lockedOpenFields.push(addWidget(new ZwWidget(m_element.exp_ticketicon_mc)) as ZwWidget);
         addWidget(new ZwWidget(m_element.expandLocked_mc));
         addWidget(new ZwWidget(m_element.expandRedeem_mc));
         addWidget(new ZwWidget(m_element.expandBuy_mc));
         if(this.m_locked)
         {
            this.m_expandMc = m_element.expandLocked_mc;
            (m_element.expandRedeem_mc as MovieClip).visible = false;
            (m_element.expandBuy_mc as MovieClip).visible = false;
         }
         else if(!Global.player.getSeenFlag(this.m_redeemItemSeenFlag))
         {
            this.m_expandMc = m_element.expandRedeem_mc;
            (m_element.expandLocked_mc as MovieClip).visible = false;
            (m_element.expandBuy_mc as MovieClip).visible = false;
         }
         else
         {
            this.m_expandMc = m_element.expandBuy_mc;
            (m_element.expandLocked_mc as MovieClip).visible = false;
            (m_element.expandRedeem_mc as MovieClip).visible = false;
         }
         for each(frameLabel in this.m_expandMc.currentLabels)
         {
            this.m_frameLabels[frameLabel.name] = frameLabel.frame;
         }
         this.m_expandMc.gotoAndStop(this.m_frameLabels[FRAMELABEL_CLOSED]);
         this.m_allToggleFields = this.m_allToggleFields.concat(this.m_unlockedOpenFields,this.m_lockedOpenFields);
         this.refreshUI();
         (m_element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.rolloverCallback);
         (m_element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.rolloutCallback);
      }
      
      private static function canTransitionToState(currentState:Number, newState:Number) : Boolean
      {
         var result:Boolean = false;
         switch(newState)
         {
            case FLYOUTSTATE_OPENED:
               result = currentState == FLYOUTSTATE_OPENING;
               break;
            case FLYOUTSTATE_OPENING:
               result = currentState == FLYOUTSTATE_CLOSED;
               break;
            case FLYOUTSTATE_CLOSED:
               result = currentState == FLYOUTSTATE_CLOSING;
               break;
            case FLYOUTSTATE_CLOSING:
               result = currentState == FLYOUTSTATE_OPENED;
         }
         return result;
      }
      
      protected function refreshUI() : void
      {
         var item:ZwWidget = null;
         var lockedWidget:ZwWidget = null;
         var unlockedWidget:ZwWidget = null;
         var flyoutOpen:Boolean = this.m_currentFlyoutState == FLYOUTSTATE_OPENED;
         for each(item in this.m_allToggleFields)
         {
            item.visible = false;
         }
         if(this.m_locked)
         {
            if(!this.m_unlockBtn.visible)
            {
               this.m_unlockBtn.visible = true;
            }
            this.m_redeemBtn.visible = false;
            this.m_buyBtn.visible = false;
            if(flyoutOpen)
            {
               for each(lockedWidget in this.m_lockedOpenFields)
               {
                  lockedWidget.visible = true;
               }
            }
         }
         else
         {
            if(!Global.player.getSeenFlag(this.m_redeemItemSeenFlag))
            {
               if(!this.m_redeemBtn.visible)
               {
                  this.m_redeemBtn.visible = true;
               }
               this.m_buyBtn.visible = false;
            }
            else
            {
               if(!this.m_buyBtn.visible)
               {
                  this.m_buyBtn.visible = true;
               }
               this.m_redeemBtn.visible = false;
            }
            this.m_unlockBtn.visible = false;
            if(flyoutOpen)
            {
               for each(unlockedWidget in this.m_unlockedOpenFields)
               {
                  unlockedWidget.visible = true;
               }
            }
         }
      }
      
      private function startMoving(newFlyoutState:Number) : void
      {
         if(!this.isFlyoutMoving() && canTransitionToState(this.m_currentFlyoutState,newFlyoutState))
         {
            this.m_currentFlyoutState = newFlyoutState;
            this.m_futureFlyoutState = FLYOUTSTATE_NOACTION;
            this.refreshUI();
            this.m_expandMc.addEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
            this.m_expandMc.gotoAndPlay(this.startFrameForFlyoutState(newFlyoutState));
         }
         else if(this.isFlyoutMoving() && newFlyoutState == this.oppositeState(this.m_currentFlyoutState))
         {
            this.m_futureFlyoutState = newFlyoutState;
         }
         else if(this.isFlyoutMoving() && this.m_currentFlyoutState == newFlyoutState)
         {
            this.m_futureFlyoutState = FLYOUTSTATE_NOACTION;
         }
      }
      
      protected function rolloverCallback(event:MouseEvent) : void
      {
         if(event.relatedObject != null && !DisplayObjectUtils.isChildOfElement(event.relatedObject as DisplayObject,event.currentTarget as DisplayObject))
         {
            this.startMoving(FLYOUTSTATE_OPENING);
         }
         else
         {
            event.stopImmediatePropagation();
         }
      }
      
      protected function rolloutCallback(event:MouseEvent) : void
      {
         if(event.relatedObject != null && !DisplayObjectUtils.isChildOfElement(event.relatedObject as DisplayObject,event.currentTarget as DisplayObject))
         {
            this.startMoving(FLYOUTSTATE_CLOSING);
         }
         else
         {
            event.stopImmediatePropagation();
         }
      }
      
      private function updateAnimation(flyoutState:Number) : void
      {
         var timer:Timer = null;
         var nextState:Number = this.nextFlyoutState(flyoutState);
         var redrawUI:Boolean = false;
         if(this.m_expandMc.currentFrame == this.startFrameForFlyoutState(nextState))
         {
            if(this.m_futureFlyoutState != FLYOUTSTATE_NOACTION)
            {
               this.m_currentFlyoutState = this.m_futureFlyoutState;
               this.m_futureFlyoutState = FLYOUTSTATE_NOACTION;
            }
            else
            {
               this.m_currentFlyoutState = this.nextFlyoutState(this.m_currentFlyoutState);
               this.m_futureFlyoutState = FLYOUTSTATE_NOACTION;
               this.m_expandMc.removeEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
               timer = new Timer(FLYOUT_FORCE_CLOSE_TIME);
               timer.addEventListener(TimerEvent.TIMER,this.closeFlyoutIfMouseLeft);
               timer.start();
               this.m_expandMc.stop();
               redrawUI = true;
            }
         }
         if(this.m_expandMc.currentFrame == this.m_frameLabels[FRAMELABEL_REFRESHUI])
         {
            redrawUI = true;
         }
         if(redrawUI)
         {
            this.refreshUI();
         }
      }
      
      private function closeFlyoutIfMouseLeft(event:TimerEvent) : void
      {
         if(this.m_expandMc == null || this.m_expandMc.stage == null)
         {
            (event.currentTarget as Timer).stop();
            (event.currentTarget as Timer).removeEventListener(TimerEvent.TIMER,this.closeFlyoutIfMouseLeft);
         }
         else if(!this.m_expandMc.hitTestPoint(this.m_expandMc.stage.mouseX,this.m_expandMc.stage.mouseY,false))
         {
            if(this.m_currentFlyoutState == FLYOUTSTATE_OPENED)
            {
               this.startMoving(FLYOUTSTATE_CLOSING);
            }
            (event.currentTarget as Timer).stop();
            (event.currentTarget as Timer).removeEventListener(TimerEvent.TIMER,this.closeFlyoutIfMouseLeft);
         }
      }
      
      protected function everyFrameCallback(event:Event) : void
      {
         if(this.isFlyoutMoving())
         {
            this.updateAnimation(this.m_currentFlyoutState);
         }
         else
         {
            this.m_expandMc.stop();
         }
      }
      
      protected function unlockButtonCallback(event:MouseEvent) : void
      {
         if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("unlock"))
         {
            this.m_callbacks.unlock(this.m_itemName);
         }
         if(Boolean(this.m_expandMc) && Boolean(m_element))
         {
            this.m_expandMc.visible = false;
            this.m_expandMc = m_element.expandRedeem_mc;
            this.m_expandMc.visible = true;
         }
      }
      
      protected function buyButtonCallback(event:MouseEvent) : void
      {
         if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("buyItem"))
         {
            this.m_callbacks.buyItem(this.m_itemName);
         }
      }
      
      protected function redeemButtonCallback(event:MouseEvent) : void
      {
         if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("redeemItem"))
         {
            this.m_callbacks.redeemItem(this.m_itemName);
         }
         if(Boolean(this.m_expandMc) && Boolean(m_element))
         {
            this.m_expandMc.visible = false;
            this.m_expandMc = m_element.expandBuy_mc;
            this.m_expandMc.visible = true;
         }
      }
      
      public function ticketsToUnlock() : Number
      {
         return this.m_ticketsToUnlock;
      }
      
      public function set unlockCost(unlockCost:Number) : void
      {
         this.m_unlockTf.text = ZLocUtils.t("Dialogs","TicketPartyFlyout_unlock",{"cost":unlockCost.toString()});
      }
      
      public function set locked(locked:Boolean) : void
      {
         this.m_locked = locked;
         this.m_expandMc.visible = false;
         if(this.m_locked)
         {
            this.m_expandMc = m_element.expandLocked_mc;
         }
         else if(!Global.player.getSeenFlag(this.m_redeemItemSeenFlag))
         {
            this.m_expandMc = m_element.expandRedeem_mc;
         }
         else
         {
            this.m_expandMc = m_element.expandBuy_mc;
         }
         this.m_expandMc.visible = true;
         this.refreshUI();
      }
      
      override public function release() : void
      {
         m_element.expandLocked_mc.removeEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
         m_element.expandRedeem_mc.removeEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
         m_element.expandBuy_mc.removeEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
         (m_element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.rolloverCallback);
         (m_element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.rolloutCallback);
         super.release();
      }
      
      private function oppositeState(flyoutState:Number) : Number
      {
         var result:Number = FLYOUTSTATE_NOACTION;
         switch(flyoutState)
         {
            case FLYOUTSTATE_OPENING:
               result = FLYOUTSTATE_CLOSING;
               break;
            case FLYOUTSTATE_CLOSING:
               result = FLYOUTSTATE_OPENING;
               break;
            case FLYOUTSTATE_OPENED:
               result = FLYOUTSTATE_CLOSED;
               break;
            case FLYOUTSTATE_CLOSED:
               result = FLYOUTSTATE_OPENED;
         }
         return result;
      }
      
      private function startFrameForFlyoutState(flyoutState:Number) : Number
      {
         var result:Number = 0;
         switch(flyoutState)
         {
            case FLYOUTSTATE_OPENED:
               result = Number(this.m_frameLabels[FRAMELABEL_CLOSING]);
               break;
            case FLYOUTSTATE_OPENING:
               result = Number(this.m_frameLabels[FRAMELABEL_OPENING]);
               break;
            case FLYOUTSTATE_CLOSED:
               result = Number(this.m_frameLabels[FRAMELABEL_CLOSED]);
               break;
            case FLYOUTSTATE_CLOSING:
               result = Number(this.m_frameLabels[FRAMELABEL_CLOSING]);
         }
         return result;
      }
      
      private function nextFlyoutState(flyoutState:Number) : Number
      {
         var result:Number = 0;
         switch(flyoutState)
         {
            case FLYOUTSTATE_OPENED:
               result = FLYOUTSTATE_CLOSING;
               break;
            case FLYOUTSTATE_OPENING:
               result = FLYOUTSTATE_OPENED;
               break;
            case FLYOUTSTATE_CLOSED:
               result = FLYOUTSTATE_OPENING;
               break;
            case FLYOUTSTATE_CLOSING:
               result = FLYOUTSTATE_CLOSED;
         }
         return result;
      }
      
      private function isFlyoutMoving() : Boolean
      {
         var result:Boolean = false;
         if(this.m_currentFlyoutState == FLYOUTSTATE_OPENING || this.m_currentFlyoutState == FLYOUTSTATE_CLOSING)
         {
            result = true;
         }
         return result;
      }
      
      public function isRedeemButtonEnabled() : Boolean
      {
         var result:Boolean = false;
         if(this.m_redeemBtn != null && this.m_redeemBtn.visible)
         {
            result = true;
         }
         return result;
      }
   }
}

