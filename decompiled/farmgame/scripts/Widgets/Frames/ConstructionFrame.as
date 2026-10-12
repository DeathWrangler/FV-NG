package Widgets.Frames
{
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.ConstructionFrameSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ConstructionFrame extends FarmSlotContainerFrame
   {
      
      protected var m_building:StorageBuilding;
      
      protected var m_window:FarmWindow;
      
      public function ConstructionFrame(element:DisplayObject, storage:StorageBuilding, parentWindow:FarmWindow)
      {
         this.m_window = parentWindow;
         this.m_building = storage;
         super(element);
         var buildingName:String = (storage as ConstructionBuilding).buildingName;
         addWidget(new ZwTextField(this.element.generic_tf,ZLocUtils.t("Dialogs",buildingName + "Title")));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ConstructionFrameSlot(slotElement,this.m_building,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var object:Object = null;
         var partItem:PartItem = null;
         var cashNeeded:int = 0;
         var index:int = 0;
         var obj:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         m_slotData = [];
         var m_usedTypes:Object = new Object();
         var objects:Array = this.m_building.getConstructionItems();
         if(objects)
         {
            for each(partItem in objects)
            {
               object = new Object();
               giftItem = partItem.item;
               giftNum = partItem.onHand;
               if(m_usedTypes[giftItem.code] == null)
               {
                  object.sendGiftsToFriends = false;
                  object.name = giftItem.name;
                  object.code = giftItem.code;
                  object.type = giftItem.type;
                  object.localizedName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  object.need = partItem.qtyNeeded;
                  m_usedTypes[giftItem.code] = giftNum;
                  m_slotData.push(object);
               }
               else
               {
                  m_usedTypes[giftItem.code] += 1;
               }
            }
            object = new Object();
            object.sendGiftsToFriends = true;
            cashNeeded = 0;
            for(index = 0; index < m_slotData.length; index++)
            {
               if(!m_slotData[index].sendGiftsToFriends)
               {
                  cashNeeded += m_slotData[index].need - m_usedTypes[m_slotData[index].code];
               }
            }
            object.cashNeeded = cashNeeded;
            m_slotData.push(object);
            for each(obj in m_slotData)
            {
               if(m_usedTypes[obj.code] != null)
               {
                  obj.amount = m_usedTypes[obj.code];
               }
            }
         }
      }
   }
}

