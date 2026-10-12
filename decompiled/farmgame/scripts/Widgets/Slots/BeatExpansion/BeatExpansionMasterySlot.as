package Widgets.Slots.BeatExpansion
{
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BeatExpansionMasterySlot extends ZwSlotFrame
   {
      
      private var m_header:ZwTextField;
      
      private var m_masteryFrame:MarketSlotMasteryFrame;
      
      private var m_icon:FarmIcon;
      
      private var m_plant_bt:FarmAnimatedTextButton;
      
      private var m_itemName:String;
      
      public function BeatExpansionMasterySlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_header = addWidget(new ZwTextField(m_element.header_tf)) as ZwTextField;
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.header_tf);
         }
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         if(m_element.hasOwnProperty("plant_bt") && Boolean(this.m_masteryFrame))
         {
            this.m_plant_bt = this.m_masteryFrame.addWidget(new FarmAnimatedTextButton(m_element.plant_bt,ZLocUtils.t("Dialogs","PlantNow"),this.onPlantNow),true) as FarmAnimatedTextButton;
         }
      }
      
      private function onPlantNow(event:Event) : void
      {
         closeParentWindow();
         UI.displayMiniMarketDialog([this.m_itemName]);
      }
      
      override public function populate(data:Object) : void
      {
         var mastery:Mastery = null;
         super.populate(data);
         var itemCode:String = data as String;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            this.m_itemName = item.name;
            this.m_header.text = item.friendlyTitle;
            this.m_header.visible = true;
            this.m_icon.loadIcon(item.icon);
            this.m_icon.visible = true;
            mastery = Global.farmGameSettingsManager.getMasteryByCode(itemCode);
            if(mastery)
            {
               this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded,true);
               this.m_masteryFrame.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_header = null;
         this.m_masteryFrame = null;
         this.m_icon = null;
         super.release();
      }
   }
}

