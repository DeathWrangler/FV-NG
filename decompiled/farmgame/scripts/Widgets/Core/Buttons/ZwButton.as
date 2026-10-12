package Widgets.Core.Buttons
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ZwButton extends ZwWidget
   {
      
      protected var m_callback:Function = null;
      
      protected var m_id:String = "";
      
      public function ZwButton(element:DisplayObject, callback:Function = null)
      {
         super(element);
         this.m_callback = callback;
         this.registerEventListener(MouseEvent.CLICK,this.preCallback);
      }
      
      public function preCallback(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
      }
      
      public function toggleClickableButton(onOff:Boolean, tooltipText:String = "") : void
      {
         if(onOff)
         {
            this.registerEventListener(MouseEvent.CLICK,this.preCallback);
            this.detachTooltip();
            if(tooltipText != "")
            {
               this.attachTooltip(new FarmTextTooltip(tooltipText));
            }
         }
         else
         {
            this.unregisterEventListener(MouseEvent.CLICK,this.preCallback);
            this.detachTooltip();
            if(tooltipText != "")
            {
               this.attachTooltip(new FarmTextTooltip(tooltipText));
            }
         }
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function set id(value:String) : void
      {
         this.m_id = value;
      }
      
      public function set callback(value:Function) : void
      {
         this.m_callback = value;
      }
   }
}

