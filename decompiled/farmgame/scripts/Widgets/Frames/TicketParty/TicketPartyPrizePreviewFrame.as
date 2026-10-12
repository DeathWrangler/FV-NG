package Widgets.Frames.TicketParty
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.TicketParty.TicketPartyPrizePreviewSlot;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TicketPartyPrizePreviewFrame extends ZwFrame
   {
      
      protected static const FRAMELABEL_CLOSED:String = "closed";
      
      protected static const FRAMELABEL_OPENED:String = "opened";
      
      protected static const FORCE_CLOSE_TIME:Number = 3000;
      
      protected var m_movieClip:MovieClip;
      
      protected var m_arrSlot:Array;
      
      protected var m_frameLabels:Object;
      
      protected var m_desiredFrame:int = 0;
      
      private var m_funcAtDesired:Function = null;
      
      protected var m_timer:Timer;
      
      protected var m_buttonCallbacks:Object;
      
      protected var m_rollInDisabled:Boolean = false;
      
      protected var m_congratulationsFrame:ZwFrame = null;
      
      protected var m_congratulationsItem:String;
      
      protected var m_featureCreditsName:String;
      
      protected var m_titleTextField:ZwTextField = null;
      
      protected var m_subtitleTextField:ZwTextField = null;
      
      public function TicketPartyPrizePreviewFrame(element:DisplayObject, featureCreditsName:String, arrItem:Array, buttonCallbacks:Object, showCongratulations:Boolean, showComplete:Boolean, congratulationsItem:String)
      {
         var frameLabel:FrameLabel = null;
         var titlePkg:String = null;
         var subtitlePkg:String = null;
         this.m_frameLabels = {};
         super(element);
         this.m_movieClip = this.element as MovieClip;
         this.m_buttonCallbacks = buttonCallbacks;
         this.m_featureCreditsName = featureCreditsName;
         for each(frameLabel in this.m_movieClip.currentLabels)
         {
            this.m_frameLabels[frameLabel.name] = frameLabel.frame;
         }
         this.m_desiredFrame = this.m_frameLabels[FRAMELABEL_CLOSED];
         this.m_movieClip.gotoAndStop(this.m_desiredFrame);
         if(m_element.hasOwnProperty("congratulations_mc") && m_element.congratulations_mc != null)
         {
            this.m_congratulationsFrame = new ZwFrame(m_element.congratulations_mc);
            this.m_congratulationsFrame.visible = false;
            if(Boolean(m_element.congratulations_mc.hasOwnProperty("okay_bt")) && m_element.congratulations_mc.okay_bt != null)
            {
               this.m_congratulationsFrame.addWidget(new FarmAnimatedButton(m_element.congratulations_mc.okay_bt,this.onCongratulationsOkay));
            }
         }
         if(m_element.hasOwnProperty("subtitle_tf") && m_element.subtitle_tf != null)
         {
            titlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsTitle",true);
            this.m_titleTextField = new ZwTextField(m_element.subtitle_tf,ZLocUtils.t(titlePkg,"CongratulationsTitle"));
         }
         if(m_element.hasOwnProperty("subtitle2_tf") && m_element.subtitle2_tf != null)
         {
            subtitlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsSubtitle",true);
            this.m_subtitleTextField = new ZwTextField(m_element.subtitle2_tf,ZLocUtils.t(subtitlePkg,"CongratulationsSubtitle"));
         }
         this.updateSlots(arrItem,showCongratulations,showComplete,congratulationsItem);
         this.m_movieClip.addEventListener(MouseEvent.MOUSE_OVER,this.rolloverCallback);
         this.m_movieClip.addEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
      }
      
      override public function release() : void
      {
         this.m_movieClip.removeEventListener(MouseEvent.MOUSE_OVER,this.rolloverCallback);
         this.m_movieClip.removeEventListener(Event.ENTER_FRAME,this.everyFrameCallback);
         this.removeTimer();
      }
      
      public function rollOut() : void
      {
         this.m_desiredFrame = this.m_frameLabels[FRAMELABEL_OPENED];
         this.m_funcAtDesired = this.resetTimer;
      }
      
      public function forceRollOut(bForce:Boolean = true) : void
      {
         this.m_rollInDisabled = bForce;
         if(bForce)
         {
            this.rollOut();
         }
         else if(!this.m_timer)
         {
            this.resetTimer();
         }
         else
         {
            this.rollIn();
         }
      }
      
      protected function rollIn() : void
      {
         this.m_desiredFrame = this.m_frameLabels[FRAMELABEL_CLOSED];
         this.m_funcAtDesired = null;
      }
      
      private function removeTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.timerDone);
            this.m_timer = null;
         }
      }
      
      private function timerDone(timerEvent:TimerEvent) : void
      {
         this.removeTimer();
         if(!this.m_rollInDisabled)
         {
            this.rollIn();
         }
      }
      
      protected function resetTimer() : void
      {
         this.removeTimer();
         if(!this.m_rollInDisabled)
         {
            this.m_timer = new Timer(FORCE_CLOSE_TIME);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.timerDone);
            this.m_timer.start();
         }
      }
      
      protected function onCongratulationsOkay(event:MouseEvent) : void
      {
         if(this.m_buttonCallbacks != null && this.m_buttonCallbacks.hasOwnProperty("redeemItem"))
         {
            this.m_buttonCallbacks.redeemItem(this.m_congratulationsItem);
         }
      }
      
      public function updateSlots(arrItem:Array, showCongratulations:Boolean, showComplete:Boolean, congratulationsItem:String) : void
      {
         var titlePkg:String = null;
         var subtitlePkg:String = null;
         var elementName:String = null;
         var slotData:Object = null;
         var slot:TicketPartyPrizePreviewSlot = null;
         if(this.m_congratulationsFrame != null)
         {
            this.m_congratulationsFrame.visible = showCongratulations;
         }
         if(this.m_titleTextField != null)
         {
            if(showComplete)
            {
               titlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsTitleComplete",true);
               this.m_titleTextField.text = ZLocUtils.t(titlePkg,"CongratulationsTitleComplete");
            }
            else
            {
               titlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsTitle",true);
               this.m_titleTextField.text = ZLocUtils.t(titlePkg,"CongratulationsTitle");
            }
         }
         if(this.m_subtitleTextField != null)
         {
            if(showComplete)
            {
               subtitlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsSubtitleComplete",true);
               this.m_subtitleTextField.text = ZLocUtils.t(subtitlePkg,"CongratulationsSubtitleComplete");
            }
            else
            {
               subtitlePkg = RewardCreditsBuilding.getLocalizedKey(this.m_featureCreditsName,"CongratulationsSubtitle",true);
               this.m_subtitleTextField.text = ZLocUtils.t(subtitlePkg,"CongratulationsSubtitle");
            }
         }
         this.m_congratulationsItem = congratulationsItem;
         if(this.m_arrSlot == null)
         {
            this.m_arrSlot = new Array();
         }
         for(var iItem:int = 0; iItem < arrItem.length; iItem++)
         {
            elementName = "slot_" + iItem.toString() + "_mc";
            if(m_element.hasOwnProperty(elementName) && m_element[elementName] != null)
            {
               slotData = arrItem[iItem];
               if(this.m_arrSlot[iItem] == null)
               {
                  slot = new TicketPartyPrizePreviewSlot(m_element[elementName],slotData.itemName,slotData.buyCost,slotData.iconURL,this.m_buttonCallbacks,slotData.locked,slotData.checked);
                  this.m_arrSlot.push(slot);
                  addWidget(slot);
               }
               else
               {
                  this.m_arrSlot[iItem].updateUI(slotData.locked,slotData.checked);
               }
               this.m_arrSlot[iItem].visible = !showCongratulations;
            }
         }
      }
      
      protected function everyFrameCallback(event:Event) : void
      {
         var frameDelta:int = this.m_desiredFrame - this.m_movieClip.currentFrame;
         if(frameDelta > 0)
         {
            this.m_movieClip.nextFrame();
         }
         else if(frameDelta < 0)
         {
            this.m_movieClip.prevFrame();
         }
         else if(this.m_funcAtDesired != null)
         {
            this.m_funcAtDesired();
            this.m_funcAtDesired = null;
         }
      }
      
      private function rolloverCallback(mouseEvent:MouseEvent) : void
      {
         this.rollOut();
      }
   }
}

