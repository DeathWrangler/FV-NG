package Display
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class CustomMouseButton extends GenericButton
   {
      
      private var m_customMouseOver:Function = null;
      
      private var m_customMouseOut:Function = null;
      
      private var m_mouseOverEnabled:Boolean = false;
      
      public function CustomMouseButton(target_mc:MovieClip, clickCallback:Function = null, customMouseOver:Function = null, customMouseOut:Function = null, val:String = "", overlayName:String = "")
      {
         super(target_mc,clickCallback,val,overlayName);
         this.m_customMouseOver = customMouseOver;
         this.m_customMouseOut = customMouseOut;
      }
      
      override protected function onOver(event:MouseEvent) : void
      {
         super.onOver(event);
         if(this.m_customMouseOver != null)
         {
            this.m_customMouseOver(event);
         }
      }
      
      override protected function onOut(event:MouseEvent) : void
      {
         super.onOut(event);
         if(this.m_customMouseOut != null)
         {
            this.m_customMouseOut(event);
         }
      }
      
      public function set mouseOverEnabled(val:Boolean) : void
      {
         this.m_mouseOverEnabled = val;
      }
      
      public function get mouseOverEnabled() : Boolean
      {
         return this.m_mouseOverEnabled;
      }
      
      override public function turnOff(keepButtonVisible:Boolean = false) : void
      {
         super.turnOff(keepButtonVisible);
         if(this.mouseOverEnabled)
         {
            m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         }
      }
      
      override public function set disabled(onOff:Boolean) : void
      {
         super.disabled = onOff;
         if(this.mouseOverEnabled)
         {
            m_overlay.visible = true;
            m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         }
      }
   }
}

