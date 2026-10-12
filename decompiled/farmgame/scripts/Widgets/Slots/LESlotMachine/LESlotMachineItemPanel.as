package Widgets.Slots.LESlotMachine
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.LESlotMachineWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class LESlotMachineItemPanel extends ZwSlotFrame
   {
      
      protected var m_iconMc:FarmIcon = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_quantityTf:ZwTextField = null;
      
      public var AnimatedSlot:Boolean = false;
      
      public function LESlotMachineItemPanel(element:DisplayObject)
      {
         super(element);
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.icon_mc != null)
         {
            this.m_iconMc = addWidget(new FarmIcon(elementMc.icon_mc)) as FarmIcon;
         }
         if(elementMc.quantity_tf != null)
         {
            this.m_quantityTf = addWidget(new ZwTextField(elementMc.quantity_tf)) as ZwTextField;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var sizeScale:Number = NaN;
         var count:int = 0;
         super.populate(data);
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconMc != null)
         {
            removeWidget(this.m_iconMc);
            this.m_iconMc = null;
         }
         var itemName:String = this.getItemNameFromData(data);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Boolean(this.AnimatedSlot == true && farmItem != null) && Boolean(m_element.icon_mc) && farmItem.getImageByName("frt_idle") != null)
         {
            sizeScale = Math.min(2,7 / (farmItem.sizeX + farmItem.sizeY) / farmItem.imageScale);
            this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.icon_mc,farmItem,null,[sizeScale],null,"frt_idle");
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            this.m_objectPreviewFrame.x = this.m_objectPreviewFrame.y = 50;
            addWidget(this.m_objectPreviewFrame,true);
         }
         else
         {
            this.m_iconMc = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_iconMc.x = this.m_iconMc.y = 0;
            this.displayIcon(data);
         }
         if(this.m_quantityTf != null)
         {
            count = this.getItemCount(data);
            if(count > 0)
            {
               this.m_quantityTf.text = "x" + count.toString();
               this.m_quantityTf.visible = true;
            }
            else
            {
               this.m_quantityTf.visible = false;
            }
         }
      }
      
      protected function getItemNameFromData(data:Object) : String
      {
         return data as String;
      }
      
      protected function displayIcon(data:Object) : void
      {
         var item:FarmItem = null;
         var itemName:String = this.getItemNameFromData(data);
         if(itemName == LESlotMachineWindow.MISS_ITEM_NAME)
         {
            this.m_iconMc.loadIcon("assets/dialogs/FV_Support/FV_FortuneWheel/FW_slotCow.png");
            this.m_iconMc.visible = true;
         }
         else if(itemName == LESlotMachineWindow.FILLER_ITEM_NAME)
         {
            this.m_iconMc.loadIcon("assets/dialogs/FV_Support/FV_FortuneWheel/FW_slotFC.png");
            this.m_iconMc.visible = true;
         }
         else
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(this.m_iconMc != null && item != null)
            {
               this.m_iconMc.loadIcon(item.iconRelativeUrl);
               this.m_iconMc.visible = true;
            }
         }
      }
      
      protected function getItemCount(data:Object) : int
      {
         return this.getItemQuantity(this.getItemNameFromData(data));
      }
      
      protected function getItemQuantity(itemName:String) : int
      {
         var result:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var itemPackageCount:int = 0;
         if(item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               itemPackageCount = item.getIntFromDataSource("itemPackage","amount");
            }
            else if(item.xml.itemPackage != null && item.xml.itemPackage.@amount != null)
            {
               itemPackageCount = int(item.xml.itemPackage.@amount);
            }
            if(item.count > 1)
            {
               result = item.count;
            }
            else if(itemPackageCount != 0)
            {
               result = itemPackageCount;
            }
         }
         return result;
      }
   }
}

