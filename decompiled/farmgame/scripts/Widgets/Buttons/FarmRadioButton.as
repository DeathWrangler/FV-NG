package Widgets.Buttons
{
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Interfaces.IZwToggle;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmRadioButton extends FarmButton implements IZwToggle
   {
      
      private static const MIN_RADIO_FRAMES:int = 2;
      
      private static const RADIO_FRAME_INACTIVE:int = 1;
      
      private static const RADIO_FRAME_ACTIVE:int = 2;
      
      protected var m_toggleMode:String = null;
      
      protected var m_radioMC:MovieClip = null;
      
      protected var m_selectCallback:Function = null;
      
      protected var m_deselectCallback:Function = null;
      
      public function FarmRadioButton(element:DisplayObject, onSelectCallback:Function = null, onDeselectCallback:Function = null)
      {
         super(element);
         this.m_selectCallback = onSelectCallback;
         this.m_deselectCallback = onDeselectCallback;
         if(this.element.hasOwnProperty("mc_radio"))
         {
            this.m_radioMC = this.element.mc_radio as MovieClip;
         }
         else
         {
            this.m_radioMC = this.element as MovieClip;
         }
         if(this.m_radioMC.totalFrames < MIN_RADIO_FRAMES)
         {
            throw new Error("Radio button movieclip needs at least " + MIN_RADIO_FRAMES + " frames. Has " + this.m_radioMC.totalFrames + " frames.");
         }
      }
      
      override public function release() : void
      {
         this.m_radioMC = null;
         this.m_selectCallback = null;
         this.m_deselectCallback = null;
         super.release();
      }
      
      public function startListenForToggle(callback:Function) : void
      {
         registerEventListener(MouseEvent.CLICK,callback);
      }
      
      public function stopListenForToggle(callback:Function) : void
      {
         unregisterEventListener(MouseEvent.CLICK,callback);
      }
      
      public function setToggleState(toggleState:String) : void
      {
         if(toggleState == ZwToggleState.DESELECTED)
         {
            this.m_radioMC.gotoAndStop(RADIO_FRAME_INACTIVE);
            if(this.m_deselectCallback != null)
            {
               this.m_deselectCallback(this);
            }
         }
         else if(toggleState == ZwToggleState.SELECTED)
         {
            this.m_radioMC.gotoAndStop(RADIO_FRAME_ACTIVE);
            if(this.m_selectCallback != null)
            {
               this.m_selectCallback(this);
            }
         }
      }
      
      public function setToggleMode(toggleMode:String) : void
      {
         this.m_toggleMode = toggleMode;
      }
   }
}

