package Classes.Doobers
{
   import Classes.FarmGameObject;
   import Classes.HarvestableResource;
   import Classes.Mastery;
   import Classes.ZItem.HarvestableItem;
   
   public class DooberMasteryReward extends DooberReward
   {
      
      protected var m_itemMastery:Mastery = null;
      
      public function DooberMasteryReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         var harvestableItem:HarvestableItem = null;
         super(rewardXml,actionObject);
         var harvestableResource:HarvestableResource = this.m_actionObject as HarvestableResource;
         if(harvestableResource)
         {
            harvestableItem = harvestableResource.getItem() as HarvestableItem;
            if(harvestableItem)
            {
               this.m_itemMastery = harvestableItem.mastery;
            }
         }
      }
      
      override public function isAvailable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_itemMastery != null)
         {
            result = this.m_itemMastery.hasAllMasteries() == false;
         }
         return result && Boolean(super.isAvailable());
      }
   }
}

