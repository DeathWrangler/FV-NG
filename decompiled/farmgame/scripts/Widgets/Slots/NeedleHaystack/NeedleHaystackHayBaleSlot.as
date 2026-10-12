package Widgets.Slots.NeedleHaystack
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NeedleHaystackHayBaleSlot extends ZwSlotFrame
   {
      
      private var m_callback:Function;
      
      private const FLOAT_HEIGHT:int = -10;
      
      private const RETURN_HEIGHT:int = 0;
      
      public function NeedleHaystackHayBaleSlot(element:DisplayObject)
      {
         var imageMc:MovieClip = null;
         super(element);
         if(m_element.image_mc != null)
         {
            imageMc = m_element.image_mc as MovieClip;
            imageMc.addEventListener(MouseEvent.MOUSE_UP,this.onClick);
            imageMc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            imageMc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      public function setSlotCallback(callback:Function) : void
      {
         this.m_callback = callback;
      }
      
      private function onClick(event:Event = null) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
      }
      
      public function setVisible(visible:Boolean) : void
      {
         (element.image_mc as MovieClip).visible = visible;
      }
      
      override public function populate(data:Object) : void
      {
      }
      
      private function onMouseOver(event:Event = null) : void
      {
         TweenMax.to(element.image_mc,1,{"y":this.FLOAT_HEIGHT});
      }
      
      private function onMouseOut(event:Event = null) : void
      {
         TweenMax.to(element.image_mc,1,{"y":this.RETURN_HEIGHT});
      }
      
      override public function release() : void
      {
         var imageMc:MovieClip = element as MovieClip;
         imageMc.removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
         imageMc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         imageMc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         super.release();
      }
   }
}

