package Widgets.Frames.SlotMachine
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class SlotMachineEmptyBonusFrame extends ZwFrame
   {
      
      public function SlotMachineEmptyBonusFrame(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","FV_WishingWell_XUK.key1")));
      }
   }
}

