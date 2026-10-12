package Widgets.Frames.Party
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class PartyCollectedItemFrame extends PartyItemFrame
   {
      
      protected var m_req:int;
      
      public function PartyCollectedItemFrame(element:DisplayObject, itemName:String, goalAmount:int)
      {
         super(element,itemName);
         this.m_req = goalAmount;
      }
      
      override protected function setupIcon() : void
      {
         var itemIcon:FarmIcon = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
         if(farmItem)
         {
            itemIcon = new FarmIcon(element.icon_mc,farmItem.icon);
            itemIcon.setIconSize(65,65);
            itemIcon.x = 2;
            itemIcon.y = -5;
            addWidget(itemIcon);
         }
      }
      
      override protected function setupButton() : void
      {
      }
      
      override protected function itemDescriptionText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_" + name);
      }
      
      override protected function itemStateText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_itemStateComplete");
      }
   }
}

