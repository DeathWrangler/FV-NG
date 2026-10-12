package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Managers.PerformanceExperimentManager;
   import Widgets.Buttons.FarmTweenedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class BuildingTooltipWindow extends StateIndicatorWindow
   {
      
      protected static const TOOLTIP_WIDTH:Number = 250;
      
      protected static const TOOLTIP_HEIGHT:Number = 140;
      
      protected static const FIRST_FRAME:Number = 1;
      
      protected static const LAST_FRAME:Number = 6;
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_Building_Tooltip.swf";
      
      private const ICON_SIZE:int = 75;
      
      protected var m_buttonText:String;
      
      private var m_buttonCallback:Function;
      
      private var m_viewPortRefreshIndex:uint = 0;
      
      protected var m_offsetX:Number;
      
      protected var m_offsetY:Number;
      
      protected var m_building:FeatureBuilding;
      
      protected var m_collapseTimer:Timer;
      
      protected var m_collapseDelay:int = -1;
      
      protected var m_expanded:Boolean = false;
      
      public function BuildingTooltipWindow(iconUrl:String, title:String, text:String, buttonText:String, timeDelay:int, buttonCallback:Function = null)
      {
         super(this.DIALOG_ASSET,iconUrl,title,text);
         this.m_buttonText = buttonText;
         this.m_buttonCallback = buttonCallback;
         this.setDelay(timeDelay);
      }
      
      protected function setDelay(newDelay:int = 0) : void
      {
         this.m_collapseDelay = newDelay;
         if(this.m_collapseTimer)
         {
            this.m_collapseTimer.removeEventListener(TimerEvent.TIMER,this.onCollapseTimer);
         }
         if(this.m_collapseDelay > 0)
         {
            this.m_collapseTimer = new Timer(this.m_collapseDelay);
            this.m_collapseTimer.addEventListener(TimerEvent.TIMER,this.onCollapseTimer);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var mainFrame:ZwFrame = new ZwFrame(m_window.tooltip_mc);
         var icon:FarmIcon = new FarmIcon(m_window.tooltip_mc.item_mc,m_iconUrl);
         icon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         mainFrame.addWidget(icon);
         mainFrame.addWidget(new ZwTextField(m_window.tooltip_mc.title_mc.title_tf,m_title));
         mainFrame.addWidget(new ZwTextField(m_window.tooltip_mc.generic_mc.generic_tf,m_text));
         mainFrame.addWidget(new FarmTweenedButton(m_window.tooltip_mc.get_bt,this.m_buttonText,this.onButtonClick));
         this.stopAnimation();
         this.updatePosition();
         addWidget(mainFrame);
         if(!Global.worldManager.isVisiting())
         {
            Global.player.avatar.conditionallyRedraw(true);
         }
      }
      
      public function setBuilding(bldg:FeatureBuilding) : void
      {
         this.m_building = bldg;
      }
      
      public function setOffsets(x:Number, y:Number) : void
      {
         this.m_offsetX = x;
         this.m_offsetY = y;
      }
      
      public function onButtonClick(event:MouseEvent = null) : void
      {
         if(this.m_buttonCallback != null)
         {
            this.m_buttonCallback();
         }
         event.stopImmediatePropagation();
      }
      
      public function updatePosition() : void
      {
         var displayObj:DisplayObject = null;
         var position:Point = null;
         if(this.m_building)
         {
            displayObj = this.m_building.getDisplayObject();
            position = displayObj.localToGlobal(new Point(displayObj.width * 0.5 + this.m_offsetX,0 - displayObj.height + this.m_offsetY));
            this.x = position.x - TOOLTIP_WIDTH * scaleX / 2;
            this.y = position.y - TOOLTIP_HEIGHT * scaleY;
         }
      }
      
      public function addListeners() : void
      {
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onRollOver,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.onRollOut,false,0,true);
         this.m_viewPortRefreshIndex = GlobalEngine.viewport.addRefreshCallback(this.updatePosition);
      }
      
      protected function stopAnimation(event:MouseEvent = null) : void
      {
         if(isLoaded())
         {
            m_window.tooltip_mc.gotoAndStop(FIRST_FRAME);
         }
      }
      
      protected function playAnimation(event:MouseEvent = null) : void
      {
         if(isLoaded() && !PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
         {
            m_window.tooltip_mc.gotoAndPlay(FIRST_FRAME);
         }
      }
      
      public function onRollOut(event:MouseEvent = null) : void
      {
         this.startTimer();
      }
      
      public function onRollOver(event:MouseEvent = null) : void
      {
         if(!this.m_expanded)
         {
            this.resetTimer();
            this.m_expanded = true;
            this.playAnimation();
         }
         else
         {
            this.resetTimer();
         }
      }
      
      private function resetTimer() : void
      {
         if(Boolean(this.m_collapseTimer) && this.m_collapseTimer.running)
         {
            this.m_collapseTimer.stop();
            this.m_collapseTimer.reset();
         }
      }
      
      private function forceResetTimer() : void
      {
         if(this.m_collapseTimer)
         {
            this.m_collapseTimer.stop();
            this.m_collapseTimer.reset();
         }
      }
      
      private function startTimer() : void
      {
         if(Boolean(this.m_collapseTimer) && this.m_collapseDelay > 0)
         {
            this.m_collapseTimer.start();
         }
      }
      
      protected function isAnimationDone() : Boolean
      {
         return m_window.tooltip_mc.currentFrame == LAST_FRAME;
      }
      
      protected function isAnimationReset() : Boolean
      {
         return m_window.tooltip_mc.currentFrame == FIRST_FRAME;
      }
      
      override public function close() : void
      {
         GlobalEngine.viewport.removeRefreshCallback(this.m_viewPortRefreshIndex);
         super.close();
      }
      
      private function onCollapseTimer(event:TimerEvent) : void
      {
         this.m_expanded = false;
         this.forceResetTimer();
         this.stopAnimation();
      }
   }
}

