package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2CraftTaskSlot extends ZwSlotFrame
   {
      
      protected var m_featureName:String;
      
      private var m_craft_icon_mc:FarmIcon;
      
      private var m_craft_name_tf:ZwTextField;
      
      private var m_craft_okay_bt:FarmAnimatedTextButton;
      
      private var m_craftItem_code:String;
      
      private var m_craftItem:FarmItem;
      
      public function AnimalSanctuaryV2CraftTaskSlot(featureName:String, element:DisplayObject)
      {
         this.m_featureName = featureName;
         super(element);
         element.visible = true;
         if(element.hasOwnProperty("craft_icon_mc"))
         {
            this.m_craft_icon_mc = new FarmIcon(element["craft_icon_mc"]);
         }
         if(element.hasOwnProperty("craft_name_tf"))
         {
            this.m_craft_name_tf = new ZwTextField(element["craft_name_tf"]);
         }
         if(element.hasOwnProperty("craft_okay_bt"))
         {
            this.m_craft_okay_bt = new FarmAnimatedTextButton(element["craft_okay_bt"],"Choose",this.onOkayButtonClick);
         }
      }
      
      private function onOkayButtonClick(event:MouseEvent) : void
      {
         if(Boolean(this.m_craftItem_code) && this.m_craftItem.hasOwnProperty("type"))
         {
            this.manager.openCraftingCottage(this.m_craftItem_code);
         }
      }
      
      override public function populate(data:Object) : void
      {
         if(data.hasOwnProperty("itemCode"))
         {
            this.m_craftItem_code = data.itemCode;
            this.m_craftItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_craftItem_code);
            if(this.m_craft_icon_mc)
            {
               if(Boolean(this.m_craftItem) && this.m_craftItem.hasOwnProperty("iconUrl"))
               {
                  this.m_craft_icon_mc.loadIcon(this.m_craftItem.iconUrl);
                  this.m_craft_icon_mc.setIconSize(50,50);
               }
               this.m_craft_icon_mc.visible = true;
            }
            if(this.m_craft_name_tf)
            {
               if(Boolean(this.m_craftItem) && this.m_craftItem.hasOwnProperty("friendlyTitle"))
               {
                  this.m_craft_name_tf.text = this.m_craftItem.friendlyTitle;
               }
               else
               {
                  this.m_craft_name_tf.text = this.m_craftItem.friendlyTitle;
               }
               this.m_craft_name_tf.visible = true;
            }
            if(this.m_craft_okay_bt)
            {
               this.m_craft_okay_bt.visible = true;
            }
         }
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance(this.m_featureName);
      }
   }
}

