package Classes
{
   import Classes.Growable.GrowableItemDelegate;
   import Classes.ZItem.AnimalItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IGrowableItem;
   import DataSources.BaseDataSource;
   import GameMode.GMAnimalPlace;
   
   public class GrowableAnimalItem extends AnimalItem implements IGrowableItem
   {
      
      private var m_growthDelegate:GrowableItemDelegate = null;
      
      public function GrowableAnimalItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         super.onConstruction(itemXML,itemData);
         this.m_growthDelegate = new GrowableItemDelegate(this);
      }
      
      public function get staticData() : Object
      {
         return this.m_growthDelegate.staticData;
      }
      
      public function get growthConsumable() : String
      {
         return this.staticData.growthConsumable;
      }
      
      public function getStage(stageName:String) : Object
      {
         return this.staticData.stages[stageName];
      }
      
      public function get farmItem() : FarmItem
      {
         return this;
      }
      
      override public function get buyableWhileVisiting() : Boolean
      {
         return false;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var currency:String = Boolean(extraData) && extraData.hasOwnProperty("currency") ? extraData.currency : "";
         Global.world.addGameMode(new GMAnimalPlace(name,false,0,true,GrowableAnimal,currency));
         return true;
      }
   }
}

