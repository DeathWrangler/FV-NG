package Widgets.Slots
{
   import Classes.MapResource;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.TransactionManager;
   import Transactions.TSetFestivalOfColorGraphic;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FestivalOfColorWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.setTimeout;
   
   public class FestivalOfColorSlot extends ZwSlotFrame
   {
      
      private const APPLY_BT:String = "apply_bt";
      
      private const LOCK_MC:String = "lock_mc";
      
      private const GLOW_MC:String = "glow_mc";
      
      private const FIREWORKS_MC:String = "fireworks_mc";
      
      private var m_applyButton:FarmAnimatedTextButton = null;
      
      private var m_glowMc:MovieClip;
      
      private var m_fireworksMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      protected var m_object:MapResource;
      
      protected var m_data:Object;
      
      protected var m_window:FarmWindow;
      
      public function FestivalOfColorSlot(element:DisplayObject, obj:MapResource, window:FarmWindow)
      {
         this.m_object = obj;
         this.m_window = window;
         super(element);
         addWidget(this.m_applyButton = new FarmAnimatedTextButton(m_element[this.APPLY_BT],"Apply",this.onApplyButtonClick),true);
         this.m_applyButton.enabled = false;
         if(m_element.hasOwnProperty(this.GLOW_MC))
         {
            this.m_glowMc = m_element[this.GLOW_MC] as MovieClip;
            this.disableGlow();
         }
         if(m_element.hasOwnProperty(this.FIREWORKS_MC))
         {
            this.m_fireworksMc = m_element[this.FIREWORKS_MC] as MovieClip;
            this.disableFireworks();
         }
         if(m_element.hasOwnProperty(this.LOCK_MC))
         {
            this.m_lockMc = m_element[this.LOCK_MC] as MovieClip;
            this.m_lockMc.visible = false;
         }
      }
      
      private function disableFireworks() : void
      {
         if(this.m_fireworksMc)
         {
            this.m_fireworksMc.gotoAndPlay(1);
            this.m_fireworksMc.visible = false;
         }
      }
      
      public function enableFireworks() : void
      {
         if(this.m_fireworksMc)
         {
            this.m_fireworksMc.gotoAndPlay(2);
            this.m_fireworksMc.visible = true;
            this.m_fireworksMc.addFrameScript(this.m_fireworksMc.totalFrames - 1,function():void
            {
               disableFireworks();
            });
         }
      }
      
      private function disableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.stop();
            this.m_glowMc.visible = false;
         }
      }
      
      private function enableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.play();
            this.m_glowMc.visible = true;
         }
      }
      
      private function disableApplyButton() : void
      {
         if(this.m_applyButton)
         {
            this.m_applyButton.enabled = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_applyButton.visible = true;
         this.m_applyButton.enabled = data.applyEnabled;
         this.m_lockMc.visible = data.locked;
         if(data.glowEnabled)
         {
            this.enableGlow();
         }
         else
         {
            this.disableGlow();
         }
         m_element.gotoAndStop(this.getColorIndex(data.colorName));
         this.m_data = data;
      }
      
      private function onApplyButtonClick(event:Event) : void
      {
         TransactionManager.addTransaction(new TSetFestivalOfColorGraphic(this.m_object,this.m_data.colorName));
         this.m_object.useAltGraphic(this.m_data.colorName);
         this.m_object.reloadImage();
         this.disableApplyButton();
         if(this.m_window)
         {
            (this.m_window as FestivalOfColorWindow).playColorBurstAnimation();
            setTimeout(function():void
            {
               m_window.refreshWindow();
            },FarmGameUtil.NUM_MSECS_IN_SECOND * 0.5);
         }
      }
      
      private function getColorIndex(colorName:String) : int
      {
         var colorIndex:int = 1;
         switch(colorName)
         {
            case "red":
               colorIndex = 2;
               break;
            case "green":
               colorIndex = 3;
               break;
            case "blue":
               colorIndex = 4;
               break;
            case "yellow":
               colorIndex = 5;
               break;
            case "purple":
               colorIndex = 6;
               break;
            default:
               colorIndex = 1;
         }
         return colorIndex;
      }
      
      override public function release() : void
      {
         this.m_object = null;
         this.m_window = null;
         super.release();
      }
   }
}

