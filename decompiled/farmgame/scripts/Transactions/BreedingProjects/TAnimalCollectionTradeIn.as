package Transactions.BreedingProjects
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import GameMode.GMMutableAnimalPlace;
   import Transactions.TFarmTransaction;
   import Widgets.Windows.Breeding.BreedingWindow;
   
   public class TAnimalCollectionTradeIn extends TFarmTransaction
   {
      
      private var m_parentWindow:BreedingWindow;
      
      private var m_collectionName:String;
      
      private var m_buildingId:int;
      
      private var m_callback:Function;
      
      public function TAnimalCollectionTradeIn(parentWindow:BreedingWindow, collectionName:String, buildingId:int, callback:Function = null)
      {
         super();
         this.m_parentWindow = parentWindow;
         this.m_collectionName = collectionName;
         this.m_buildingId = buildingId;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onTradeCollection",this.m_parentWindow.getFeatureName(),this.m_collectionName,this.m_buildingId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var item:FarmItem = null;
         var mutableState:MutableAnimalState = null;
         if(result)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(result.itemName);
            if(item != null)
            {
               Global.player.addMutableItemToGiftbox(item.code,result.mutableState);
               mutableState = MutableAnimalState.createFromPhpString("",result.mutableState);
               Global.world.addGameMode(new GMMutableAnimalPlace(mutableState.getPackedMutableState(),result.itemName,true,-1,false),false);
               this.m_parentWindow.close();
            }
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

