package Classes.Doobers
{
   import Classes.FarmGameObject;
   import Classes.HarvestableResource;
   import Classes.ZItem.HarvestableItem;
   
   public class DooberBushelReward extends DooberReward
   {
      
      public function DooberBushelReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         super(rewardXml,actionObject);
      }
      
      override public function isAvailable() : Boolean
      {
         var harvestableItem:HarvestableItem = null;
         var bushelItemCode:String = null;
         var result:Boolean = false;
         var harvestableResource:HarvestableResource = this.m_actionObject as HarvestableResource;
         if(harvestableResource)
         {
            harvestableItem = harvestableResource.getItem() as HarvestableItem;
            if(harvestableItem)
            {
               bushelItemCode = harvestableItem.bushelItemCode;
               if(null != bushelItemCode && "" != bushelItemCode)
               {
                  result = true;
               }
            }
         }
         return result;
      }
   }
}

