package Widgets.Slots.UGC
{
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Slots.ZwToggleSlotFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   
   public class UGCColorSlot extends ZwToggleSlotFrame
   {
      
      private var m_data:Object;
      
      private var m_rollover:ZwFrame;
      
      private var m_shape:Shape;
      
      public function UGCColorSlot(element:DisplayObject)
      {
         super(element);
         this.m_shape = new Shape();
         if(ObjectUtil.pathExists(m_element,"rollover_mc"))
         {
            this.m_rollover = new ZwFrame(m_element.rollover_mc);
            addWidget(this.m_rollover,false);
            this.addRolloverListeners();
         }
         if(ObjectUtil.pathExists(m_element,"color_mc"))
         {
            addWidget(new ZwFrame(m_element.color_mc));
            m_element.color_mc.addChild(this.m_shape);
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      private function addRolloverListeners() : void
      {
         registerEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         registerEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      private function removeRolloverListeners() : void
      {
         unregisterEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         unregisterEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      override protected function select() : void
      {
         this.removeRolloverListeners();
         this.onRollOver();
      }
      
      override protected function deselect() : void
      {
         this.onRollOut();
         this.addRolloverListeners();
      }
      
      override public function release() : void
      {
         this.m_rollover = null;
         this.m_shape = null;
         super.release();
      }
      
      override public function clearView() : void
      {
         super.clearView();
         detachTooltip();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_data.name)));
         this.m_shape.graphics.clear();
         this.m_shape.graphics.beginFill(this.m_data.color,1);
         this.m_shape.graphics.drawRect(0,0,75,75);
         this.m_shape.graphics.endFill();
         getWidget(element.color_mc).visible = true;
      }
      
      private function onRollOver(event:MouseEvent = null) : void
      {
         if(this.m_rollover != null)
         {
            this.m_rollover.visible = true;
         }
      }
      
      private function onRollOut(event:MouseEvent = null) : void
      {
         if(this.m_rollover != null)
         {
            this.m_rollover.visible = false;
         }
      }
   }
}

