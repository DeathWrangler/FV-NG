package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Breeding.NurseryContentsSlot;
   import flash.events.MouseEvent;
   
   public class NurseryContentsWindow extends AnimalBreedingContentsWindow
   {
      
      protected var m_buyContaineePartButton:FarmAnimatedTextButton;
      
      protected var m_totalContaineePartCount:ZwTextField = null;
      
      private var m_expText:ZwTextField = null;
      
      public function NurseryContentsWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function getFarmSlotContainerFrame() : FarmSlotContainerFrame
      {
         return new StorageContentsSlotFrame(m_window.animals_mc,m_contents,this,NurseryContentsSlot);
      }
      
      public function get containeePartCountTextField() : ZwTextField
      {
         return this.m_totalContaineePartCount;
      }
      
      override protected function initFeatureWidgets() : void
      {
         super.initFeatureWidgets();
         this.m_buyContaineePartButton = new FarmAnimatedTextButton(m_window.buy_btn,ZLocUtils.t("Dialogs",this.m_building.bldgName + "_buyContaineePart"),this.onBuyContaineePart);
         addWidget(this.m_buyContaineePartButton);
         this.m_totalContaineePartCount = new ZwTextField(m_window.feed_tf,this.containeePartRemaining.toString());
         addWidget(this.m_totalContaineePartCount);
         this.m_expText = new ZwTextField(m_window.expand_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_building.bldgName + "_Expand_Message"));
         addWidget(this.m_expText);
         this.updateSlotButtons();
      }
      
      public function onBuyContaineePart(event:MouseEvent = null) : void
      {
         var createWindow:Function;
         var items:Array;
         var building:FeatureBuilding = null;
         building = m_building;
         FarmStatsManager.count(m_building.getItemName(),"content_window","buy_more_" + this.containeePart);
         createWindow = function(purchased:Boolean = false):void
         {
            m_totalContaineePartCount.text = containeePartRemaining.toString();
            updateSlotButtons();
            building.displayStorageDialog();
            var bought:String = purchased ? "true" : "false";
            FarmStatsManager.count(m_building.getItemName(),"buy_market_" + containeePart,bought);
         };
         items = this.containeePartMarketItems;
         UI.displayMiniMarketDialog(items,"animal","animal",createWindow,false);
      }
      
      protected function get containeePartMarketItems() : Array
      {
         var items:Array = new Array();
         items.push(this.containeePart);
         return items;
      }
      
      public function get containeePartRemaining() : int
      {
         return Global.player.getGiftCountForItem(this.containeePart);
      }
      
      public function get containeePart() : String
      {
         return m_building.containeeManager.containeeParts[0];
      }
      
      public function updateSlotButtons() : void
      {
         var slot:NurseryContentsSlot = null;
         for each(slot in m_content_mc.slots)
         {
            slot.updateButtons();
         }
      }
      
      override protected function generateMetadataArrContents(metadataList:Array, contents:Array, itemCode:String) : Array
      {
         var meta:Object = null;
         var quantity:int = 0;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         for each(meta in metadataList)
         {
            quantity = 1;
            contents.push({
               "code":itemCode,
               "quantity":quantity,
               "itemName":farmItem.name,
               "name":farmItem.friendlyTitle,
               "metadataHash":meta.key,
               "metadata":meta.data,
               "unique":true
            });
         }
         return contents;
      }
   }
}

