package Widgets.Frames.Party
{
   import Classes.Avatar.AvatarItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class PartyItemFrame extends ZwFrame
   {
      
      protected var m_itemName:String;
      
      public function PartyItemFrame(element:DisplayObject, itemName:String)
      {
         super(element);
         this.m_itemName = itemName;
         this.setupFrame();
      }
      
      private function setupFrame() : void
      {
         var element:Object = this.element;
         var itemTitleTextField:ZwTextField = addWidget(new ZwTextField(element.generic1_tf,ZLocUtils.tk_pk_asTitle(this.itemNameText()))) as ZwTextField;
         var itemDescriptionTextField:ZwTextField = addWidget(new ZwTextField(element.generic2_tf,this.itemDescriptionText())) as ZwTextField;
         var itemCompleteTextField:ZwTextField = addWidget(new ZwTextField(element.generic3_tf,this.itemStateText())) as ZwTextField;
         this.setupIcon();
         this.setupButton();
      }
      
      private function itemNameText() : String
      {
         var result:String = "Items:PartyItemSurprise";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         var avatarItem:AvatarItem = null;
         if(Global.avatarConfigSettings)
         {
            avatarItem = Global.avatarConfigSettings.getItemByName(this.m_itemName);
         }
         if(item)
         {
            result = item.friendlyName;
         }
         else if(avatarItem)
         {
            result = avatarItem.friendlyName;
         }
         return result;
      }
      
      protected function itemDescriptionText() : String
      {
         return "Item Description";
      }
      
      protected function itemStateText() : String
      {
         return "";
      }
      
      protected function setupIcon() : void
      {
      }
      
      protected function setupButton() : void
      {
      }
   }
}

