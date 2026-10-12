package Widgets.Core.Base
{
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import flash.display.DisplayObject;
   
   public class ZwWidget extends ZwEventWidget
   {
      
      protected var m_tooltip:ZwAbstractTooltip = null;
      
      public function ZwWidget(element:DisplayObject)
      {
         super(element);
      }
      
      override public function release() : void
      {
         if(this.m_tooltip)
         {
            this.m_tooltip.release();
            this.m_tooltip = null;
         }
         super.release();
      }
      
      public function attachTooltip(tooltip:ZwAbstractTooltip) : Boolean
      {
         var result:Boolean = false;
         if(null == this.m_tooltip)
         {
            this.m_tooltip = tooltip;
            this.m_tooltip.attach(this);
            result = true;
         }
         return result;
      }
      
      public function detachTooltip() : ZwAbstractTooltip
      {
         var result:ZwAbstractTooltip = this.m_tooltip;
         if(this.m_tooltip)
         {
            this.m_tooltip.detach();
            this.m_tooltip = null;
         }
         return result;
      }
      
      public function get tooltip() : ZwAbstractTooltip
      {
         return this.m_tooltip;
      }
   }
}

