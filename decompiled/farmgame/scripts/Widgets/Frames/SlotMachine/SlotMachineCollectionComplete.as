package Widgets.Frames.SlotMachine
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class SlotMachineCollectionComplete extends ZwFrame
   {
      
      public function SlotMachineCollectionComplete(element:DisplayObject, buildingName:String)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",buildingName + "_CollectionComplete")));
      }
   }
}

