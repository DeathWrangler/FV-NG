package Widgets.Frames.SlotMachine
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class SlotMachineCompleteFrame extends ZwFrame
   {
      
      protected var m_building:FeatureBuilding;
      
      public function SlotMachineCompleteFrame(element:DisplayObject, building:FeatureBuilding)
      {
         var index:String = null;
         var reward:FarmItem = null;
         var elementName:String = null;
         super(element);
         this.m_building = building;
         var buildingName:String = this.m_building.getItem().name;
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","Congratulations")));
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs",buildingName + "_AllComplete")));
         var rewardData:Array = this.m_building.slotmachine.rewardData;
         for(index in rewardData)
         {
            reward = rewardData[index].item;
            elementName = "icon_" + index + "_mc";
            if(m_element[elementName] != null)
            {
               addWidget(new FarmIcon(m_element[elementName],reward.iconUrl));
            }
         }
      }
   }
}

