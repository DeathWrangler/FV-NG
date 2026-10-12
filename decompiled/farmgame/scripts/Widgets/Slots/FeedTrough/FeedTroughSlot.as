package Widgets.Slots.FeedTrough
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class FeedTroughSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:Number = 75;
      
      public function FeedTroughSlot(element:DisplayObject)
      {
         super(element);
      }
      
      override public function populate(data:Object) : void
      {
         var animalItem:FarmItem;
         var icon:FarmIcon;
         var iconUrl:String = null;
         var tapeFrame:ZwFrame = null;
         var foundFrame:ZwFrame = null;
         super.populate(data);
         animalItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            iconUrl = animalItem.getStringFromDataSourceArray("name","mugshot","url","image");
         }
         else
         {
            iconUrl = animalItem.xml.image.(@name == "mugshot").@url;
         }
         if(iconUrl.length == 0)
         {
            iconUrl = animalItem.icon;
         }
         icon = new FarmIcon(m_element.icon_mc,iconUrl);
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(icon);
         addWidget(new ZwFrame(m_element.whiteFrame_mc));
         addWidget(new ZwFrame(m_element.tack_mc));
         addWidget(new ZwFrame(m_element.shine_mc));
         if(data.newItem == true && data.foundItem == false)
         {
            tapeFrame = new ZwFrame(m_element.tape_mc);
            tapeFrame.addWidget(new ZwTextField(m_element.tape_mc.new_tf,ZLocUtils.t("Dialogs","NewLabel")));
            addWidget(tapeFrame);
         }
         if(data.foundItem == true)
         {
            foundFrame = new ZwFrame(element.found_mc);
            foundFrame.addWidget(new ZwTextField(m_element.found_mc.found_tf,ZLocUtils.t("Dialogs","FoundLabel")));
            addWidget(foundFrame);
         }
      }
   }
}

