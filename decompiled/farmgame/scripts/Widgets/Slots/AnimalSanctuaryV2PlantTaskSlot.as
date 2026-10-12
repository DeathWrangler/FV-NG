package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2PlantTaskSlot extends ZwSlotFrame
   {
      
      protected var m_featureName:String;
      
      private var m_plant_icon_mc:FarmIcon;
      
      private var m_plant_name_tf:ZwTextField;
      
      private var m_plant_okay_bt:FarmAnimatedTextButton;
      
      private var m_plantItem_code:String;
      
      private var m_plantItem:FarmItem;
      
      private var m_count_tf:ZwTextField;
      
      public function AnimalSanctuaryV2PlantTaskSlot(featureName:String, element:DisplayObject)
      {
         this.m_featureName = featureName;
         super(element);
         element.visible = true;
         if(element.hasOwnProperty("plant_icon_mc"))
         {
            this.m_plant_icon_mc = new FarmIcon(element["plant_icon_mc"]);
         }
         if(element.hasOwnProperty("plant_name_tf"))
         {
            this.m_plant_name_tf = new ZwTextField(element["plant_name_tf"]);
         }
         if(element.hasOwnProperty("plant_okay_bt"))
         {
            this.m_plant_okay_bt = new FarmAnimatedTextButton(element["plant_okay_bt"],"Choose",this.onOkayButtonClick);
         }
         if(element.hasOwnProperty("count_tf"))
         {
            this.m_count_tf = new ZwTextField(element["count_tf"]);
         }
      }
      
      private function onOkayButtonClick(event:MouseEvent) : void
      {
         if(Boolean(this.m_plantItem) && this.m_plantItem.hasOwnProperty("name"))
         {
            this.manager.onClickPlantFromWindow(this.m_plantItem.name,"Plant");
         }
      }
      
      override public function populate(data:Object) : void
      {
         if(data.hasOwnProperty("itemCode"))
         {
            this.m_plantItem_code = data.itemCode;
            this.m_plantItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_plantItem_code);
            if(this.m_plant_icon_mc)
            {
               if(Boolean(this.m_plantItem) && this.m_plantItem.hasOwnProperty("iconUrl"))
               {
                  this.m_plant_icon_mc.loadIcon(this.m_plantItem.iconUrl);
                  this.m_plant_icon_mc.setIconSize(50,50);
               }
               this.m_plant_icon_mc.visible = true;
               this.m_plant_icon_mc.attachTooltip(new FarmTextTooltip("More harvest time gives more coupons!"));
            }
            if(this.m_plant_name_tf)
            {
               if(Boolean(this.m_plantItem) && this.m_plantItem.hasOwnProperty("friendlyTitle"))
               {
                  this.m_plant_name_tf.text = this.m_plantItem.friendlyTitle;
               }
               else
               {
                  this.m_plant_name_tf.text = this.m_plantItem.friendlyTitle;
               }
               this.m_plant_name_tf.visible = true;
            }
            if(this.m_plant_okay_bt)
            {
               this.m_plant_okay_bt.visible = true;
            }
            if(this.m_count_tf)
            {
               this.m_count_tf.text = "Harvest \n" + (100 - this.manager.getCropProgress(this.m_plantItem.name)).toString() + " more";
               this.m_count_tf.visible = true;
            }
         }
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance(this.m_featureName);
      }
   }
}

