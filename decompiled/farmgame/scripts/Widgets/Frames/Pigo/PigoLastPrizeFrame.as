package Widgets.Frames.Pigo
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class PigoLastPrizeFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const INTRO_ANIMATION:String = "intro";
      
      private static const OUTRO_ANIMATION:String = "outro";
      
      private static const QUEUE_TIMER_DELAY:int = 1500;
      
      private var m_container:ZwFrame;
      
      private var m_icon:FarmIcon;
      
      private var m_itemNameTextField:ZwTextField;
      
      private var m_currentItemName:String;
      
      private var m_itemNameQueue:Array = new Array();
      
      private var m_lastFrame:int;
      
      private var m_currentAnimation:String;
      
      private var m_queueTimer:Timer;
      
      public function PigoLastPrizeFrame(element:DisplayObject)
      {
         super(element);
         this.m_container = addWidget(new ZwFrame(m_element.rightPanelReward_mc),false) as ZwFrame;
         this.m_icon = addWidget(new FarmIcon(m_element.rightPanelReward_mc.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_itemNameTextField = addWidget(new ZwTextField(m_element.rightPanelReward_mc.itemTitle_tf," ")) as ZwTextField;
         this.m_queueTimer = new Timer(QUEUE_TIMER_DELAY,1);
         this.m_queueTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onQueueTimerComplete);
      }
      
      override public function release() : void
      {
         this.m_container = null;
         this.m_icon = null;
         this.m_itemNameTextField = null;
         this.m_itemNameQueue = null;
         this.m_queueTimer.stop();
         this.m_queueTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onQueueTimerComplete);
         this.m_queueTimer = null;
         Global.stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         super.release();
      }
      
      public function queueItem(itemName:String) : void
      {
         this.m_itemNameQueue.push(itemName);
         if(this.m_currentItemName == null)
         {
            this.displayNextItem();
         }
         else
         {
            this.m_queueTimer.reset();
            this.m_queueTimer.start();
         }
      }
      
      private function displayNextItem() : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         if(this.m_itemNameQueue.length > 0)
         {
            itemName = this.m_itemNameQueue.shift();
            if(this.m_currentItemName != itemName)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(item)
               {
                  this.m_icon.loadIcon(item.iconUrl);
                  this.m_currentItemName = itemName;
                  this.m_itemNameTextField.text = item.friendlyTitle;
               }
            }
            this.playIntro();
         }
      }
      
      private function playIntro() : void
      {
         this.m_container.visible = true;
         this.m_currentAnimation = INTRO_ANIMATION;
         this.m_lastFrame = -1;
         Global.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         (m_element as MovieClip).gotoAndPlay(INTRO_ANIMATION);
      }
      
      private function playOutro() : void
      {
         this.m_currentAnimation = OUTRO_ANIMATION;
         this.m_lastFrame = -1;
         Global.stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         (m_element as MovieClip).gotoAndPlay(OUTRO_ANIMATION);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var currentFrame:int = (m_element as MovieClip).currentFrame;
         if(currentFrame == this.m_lastFrame)
         {
            Global.stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            switch(this.m_currentAnimation)
            {
               case INTRO_ANIMATION:
                  if(this.m_itemNameQueue.length > 0)
                  {
                     this.m_queueTimer.reset();
                     this.m_queueTimer.start();
                  }
                  break;
               case OUTRO_ANIMATION:
                  this.m_currentItemName = null;
                  this.m_container.visible = false;
                  this.displayNextItem();
            }
         }
         else
         {
            this.m_lastFrame = currentFrame;
         }
      }
      
      private function onQueueTimerComplete(event:TimerEvent) : void
      {
         this.displayNextItem();
      }
   }
}

