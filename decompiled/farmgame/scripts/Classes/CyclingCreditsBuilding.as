package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   
   public class CyclingCreditsBuilding extends RewardCreditsBuilding
   {
      
      public function CyclingCreditsBuilding(buildingType:String = null)
      {
         var featureName:String = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingType);
         if(item != null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               featureName = item.getStringFromDataSource("featureName");
            }
            else
            {
               featureName = item.xml.featureName.toString();
            }
         }
         super(buildingType,featureName);
      }
      
      override public function isFull() : Boolean
      {
         return this.getCurrentCredits() >= m_capacity;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var result:Boolean = false;
         if(!this.isFull())
         {
            result = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         }
         return result;
      }
      
      protected function reset() : void
      {
         Global.player.addFeatureCredits(m_creditsFeatureName,this.getCurrentCredits() * -1);
         setState(STATE_BUILT);
      }
   }
}

