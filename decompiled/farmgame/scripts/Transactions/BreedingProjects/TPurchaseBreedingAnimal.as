package Transactions.BreedingProjects
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.MutableAnimalState;
   import GameMode.GMMutableAnimalPlace;
   import Transactions.TFarmTransaction;
   import Widgets.Windows.Breeding.BreedingWindow;
   
   public class TPurchaseBreedingAnimal extends TFarmTransaction
   {
      
      private var m_featureName:String = "";
      
      private var m_gender:String;
      
      private var m_baseColor:String;
      
      private var m_patternColor:String;
      
      private var m_patternStyle:String;
      
      private var m_breedingWindow:BreedingWindow;
      
      private var m_callback:Function;
      
      public function TPurchaseBreedingAnimal(featureName:String, gender:String, baseColor:String, patternColor:String, patternStyle:String, breedingWindow:BreedingWindow, callback:Function = null)
      {
         super();
         this.m_featureName = featureName;
         this.m_gender = gender;
         this.m_baseColor = baseColor;
         this.m_patternColor = patternColor;
         this.m_patternStyle = patternStyle;
         this.m_breedingWindow = breedingWindow;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onPurchaseBreedingAnimal",this.m_featureName,this.m_gender,this.m_baseColor,this.m_patternColor,this.m_patternStyle);
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
               this.m_breedingWindow.close();
            }
         }
      }
   }
}

