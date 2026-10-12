package Widgets.Slots.Lottery
{
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LotteryPickSlot extends ZwSlotFrame
   {
      
      private var m_ticketNumbers:Vector.<Number>;
      
      private var m_slotNumber:int;
      
      private var m_pickCheckMark:ZwBaseWidget;
      
      private var m_data:Object;
      
      private var m_selected:Boolean;
      
      private var m_number:FarmAnimatedButton;
      
      private var m_numberText:ZwTextField;
      
      private var m_clickCallback:Function;
      
      public function LotteryPickSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         this.m_ticketNumbers = new Vector.<Number>();
         this.m_clickCallback = clickCallback;
         this.m_selected = false;
         var slotName:String = m_element.name;
         this.m_number = addWidget(new FarmAnimatedButton(m_element.picker_bt,this.onPickNumber)) as FarmAnimatedButton;
         this.m_numberText = addWidget(new ZwTextField(m_element.picker_bt.generic_tf)) as ZwTextField;
         this.m_pickCheckMark = addWidget(new ZwBaseWidget(m_element.mypickCheckmark_mc)) as ZwBaseWidget;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data.hasOwnProperty("data") && this.m_data["data"] != null)
         {
            this.m_numberText.text = this.m_data["data"].toString();
            this.m_number.visible = true;
            this.m_numberText.visible = true;
         }
         if(this.m_data.hasOwnProperty("selected") && this.m_data["selected"] == true)
         {
            this.m_pickCheckMark.visible = true;
         }
      }
      
      private function onPickNumber(event:Event) : void
      {
         var selectedNumber:String = null;
         var returnCallBackValue:Boolean = false;
         if(this.m_clickCallback != null)
         {
            selectedNumber = this.m_numberText.text;
            returnCallBackValue = this.m_clickCallback(selectedNumber);
         }
         this.m_pickCheckMark.visible = returnCallBackValue;
      }
   }
}

