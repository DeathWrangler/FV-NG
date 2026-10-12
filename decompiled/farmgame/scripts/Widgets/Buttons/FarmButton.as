package Widgets.Buttons
{
   import Classes.Constants.ClickTrackingConstants;
   import Managers.ClickTrackingManager;
   import Widgets.Core.Buttons.ZwButton;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   
   public class FarmButton extends ZwButton
   {
      
      public function FarmButton(element:DisplayObject, callback:Function = null)
      {
         super(element,callback);
         this.registerEventListener(MouseEvent.CLICK,this.onTrackedClick);
      }
      
      protected function onTrackedClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
      }
      
      public function set applyGrayOut(onOff:Boolean) : void
      {
         var matrix:Array = null;
         if(onOff)
         {
            matrix = new Array();
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0.2989,0.587,0.114,0,0]);
            matrix = matrix.concat([0,0,0,1,0]);
            m_element.filters = [new ColorMatrixFilter(matrix)];
         }
         else
         {
            m_element.filters = [];
         }
      }
      
      override public function toggleClickableButton(onOff:Boolean, tooltipText:String = "") : void
      {
         super.toggleClickableButton(onOff,tooltipText);
         if(onOff)
         {
            this.enabled = true;
            this.registerEventListener(MouseEvent.CLICK,this.onTrackedClick);
            this.applyGrayOut = false;
         }
         else
         {
            this.enabled = false;
            this.unregisterEventListener(MouseEvent.CLICK,this.onTrackedClick);
            this.applyGrayOut = true;
         }
      }
   }
}

