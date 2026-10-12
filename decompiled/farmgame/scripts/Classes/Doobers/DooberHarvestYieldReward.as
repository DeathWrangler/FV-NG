package Classes.Doobers
{
   import Classes.FarmGameObject;
   import Classes.HarvestYield;
   import Classes.ItemInstance;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   
   public class DooberHarvestYieldReward extends DooberReward
   {
      
      private var m_yieldType:String = "";
      
      public function DooberHarvestYieldReward(rewardXml:XML, actionObject:FarmGameObject, type:String)
      {
         super(rewardXml,actionObject);
         this.m_yieldType = type;
         m_amount = NO_AMOUNT_SET;
      }
      
      override public function getAmount() : int
      {
         var actionItem:FarmItem = null;
         var yields:Vector.<HarvestYield> = null;
         var yield:HarvestYield = null;
         var result:int = super.getAmount();
         if(result == NO_AMOUNT_SET)
         {
            if(m_actionObject is ItemInstance)
            {
               actionItem = (m_actionObject as ItemInstance).getItem();
               if(actionItem is HarvestableItem)
               {
                  yields = (actionItem as HarvestableItem).harvestYields;
                  for each(yield in yields)
                  {
                     if(yield.type == this.m_yieldType)
                     {
                        m_amount = result = Math.ceil(yield.yield);
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      override public function isAvailable() : Boolean
      {
         return this.getAmount() > 0 && Boolean(super.isAvailable());
      }
   }
}

