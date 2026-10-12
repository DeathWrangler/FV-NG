package Widgets.Slots
{
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.Interfaces.IZwToggle;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ZwToggleSlotFrame extends ZwSlotFrame implements IZwToggle
   {
      
      protected var m_selectCallback:Function;
      
      protected var m_deselectCallback:Function;
      
      public function ZwToggleSlotFrame(element:DisplayObject, selectCallback:Function = null, deselectCallback:Function = null)
      {
         super(element);
         this.m_selectCallback = selectCallback;
         this.m_deselectCallback = deselectCallback;
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
         switch(toggleState)
         {
            case ZwToggleState.SELECTED:
               this.select();
               break;
            case ZwToggleState.DESELECTED:
               this.deselect();
               break;
            case ZwToggleState.DISABLED:
               this.disable();
         }
      }
      
      public function setToggleMode(toggleMode:String) : void
      {
      }
      
      protected function select() : void
      {
         if(this.m_selectCallback != null)
         {
            this.m_selectCallback(this);
         }
      }
      
      protected function deselect() : void
      {
         if(this.m_deselectCallback != null)
         {
            this.m_deselectCallback(this);
         }
      }
      
      protected function disable() : void
      {
      }
   }
}

