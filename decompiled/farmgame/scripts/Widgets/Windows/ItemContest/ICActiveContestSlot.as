package Widgets.Windows.ItemContest
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ICActiveContestSlot extends ZwSlotFrame
   {
      
      private var m_window:ItemContestWindow;
      
      private var m_contestName:String = null;
      
      private var m_contestNameField:ZwTextField = null;
      
      private var m_button:ZwButton = null;
      
      public function ICActiveContestSlot(element:DisplayObject, parentWindow:ItemContestWindow)
      {
         super(element);
         this.m_window = parentWindow;
         if(m_element.hasOwnProperty("generic_tf"))
         {
            this.m_contestNameField = addWidget(new ZwTextField(m_element.generic_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("button_bt"))
         {
            m_element.button_bt.buttonMode = true;
            this.m_button = addWidget(new FarmAnimatedButton(m_element.button_bt,this.onClick)) as ZwButton;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_window = null;
         this.m_contestNameField = null;
         this.m_button = null;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var contestName:String = String(data);
         this.m_contestName = contestName;
         this.m_contestNameField.text = ZLocUtils.t("Dialogs","Contest_" + this.m_contestName);
         this.m_contestNameField.visible = true;
         this.m_contestNameField.enabled = false;
         if(m_element.hasOwnProperty("selected_mc"))
         {
            if(this.m_window.getSelectedContestName() == contestName)
            {
               m_element.selected_mc.visible = true;
            }
            else
            {
               m_element.selected_mc.visible = false;
            }
         }
         this.m_button.visible = true;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         this.m_window.setSelectedContest(this.m_contestName);
      }
   }
}

