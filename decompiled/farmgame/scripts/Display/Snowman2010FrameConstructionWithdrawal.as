package Display
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   
   public class Snowman2010FrameConstructionWithdrawal extends Snowman2010Dialog
   {
      
      public function Snowman2010FrameConstructionWithdrawal(building:StorageBuilding)
      {
         super(building);
      }
      
      override protected function pushNewData() : void
      {
         var object:Object = null;
         var partItem:PartItem = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         var objects:Array = m_building.getConstructionItems();
         var sumOfParts:int = 0;
         var sumOfNeededParts:int = 0;
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
                  object.friendlyName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  object.currentCount = partItem.onHand;
                  object.needCount = partItem.qtyNeeded;
                  sumOfNeededParts += partItem.qtyNeeded;
                  m_usedTypes[giftItem.code] = giftNum;
                  sumOfParts += giftNum;
                  m_data.push(object);
               }
               else
               {
                  m_usedTypes[giftItem.code] += 1;
                  sumOfParts += 1;
               }
            }
            m_window.main_mc.meter_mc.bar_mc.width = sumOfParts / sumOfNeededParts * BAR_WIDTH;
         }
      }
   }
}

