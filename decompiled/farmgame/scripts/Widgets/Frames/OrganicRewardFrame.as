package Widgets.Frames
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class OrganicRewardFrame extends ZwFrame
   {
      
      public function OrganicRewardFrame(element:DisplayObject, iconUrl:String, quantity:int)
      {
         super(element);
         this.setUpSlot(iconUrl,quantity);
      }
      
      private function setUpSlot(iconUrl:String, quantity:int) : void
      {
         var rewardString:String = null;
         if(m_element)
         {
            addWidget(new FarmIcon(m_element.icon_mc as DisplayObject,iconUrl),true);
         }
         if(m_element.hasOwnProperty("quantity_tf"))
         {
            rewardString = "x" + quantity.toString();
            addWidget(new ZwTextField(m_element.quantity_tf,rewardString),true);
         }
      }
   }
}

