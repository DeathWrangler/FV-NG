package Widgets.Windows
{
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class PPHLimitCheckMark extends ZwFrame
   {
      
      private var m_selected:Boolean;
      
      public function PPHLimitCheckMark(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwFrame(m_element as DisplayObject));
         m_element.gotoAndStop(1);
         this.m_selected = false;
         this.registerEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function get checkSelected() : Boolean
      {
         return this.m_selected;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_selected)
         {
            this.m_selected = false;
            m_element.gotoAndStop(1);
         }
         else
         {
            this.m_selected = true;
            m_element.gotoAndStop(2);
         }
      }
   }
}

