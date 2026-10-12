package GameMode
{
   import Classes.FarmGameObject;
   import Classes.FeatureBuilding;
   import Classes.MutableAnimal;
   import Engine.Transactions.Transaction;
   import Transactions.TBreedAnimalPlace;
   import flash.events.MouseEvent;
   
   public class GMMutableAnimalPlace extends GMAnimalPlace
   {
      
      private var m_breedMetadata:String;
      
      private var m_animal:MutableAnimal = null;
      
      private var m_fromMarket:Boolean = false;
      
      public function GMMutableAnimalPlace(metadata:Object, animalType:String = null, isGift:Boolean = false, buildingId:Number = 0, repopGift:Boolean = true, fromMarket:Boolean = false, overrideClass:Class = null)
      {
         this.m_breedMetadata = metadata as String;
         this.m_fromMarket = fromMarket;
         super(animalType,isGift,buildingId,repopGift,overrideClass);
      }
      
      override protected function createSelectedObject() : void
      {
         m_highlightedPoint = getMouseTilePos();
         this.m_animal = m_overrideClass ? new m_overrideClass(m_animalType,this.m_breedMetadata) : new MutableAnimal(m_animalType,this.m_breedMetadata);
         this.m_animal.setOuter(Global.world);
         this.m_animal.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         this.m_animal.fromMarket = this.m_fromMarket;
         m_selectedObject = this.m_animal as FarmGameObject;
      }
      
      override protected function createTransaction() : Transaction
      {
         return new TBreedAnimalPlace(m_selectedObject as MutableAnimal,m_isGift,m_cid);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(m_cid) as FeatureBuilding;
         if(featureBuilding != null)
         {
            featureBuilding.lastMetaHashRemoved = this.m_animal.getMetadataKey();
         }
         if(this.m_isGift)
         {
            this.m_storedOrigin = -1;
         }
         return super.onMouseUp(event);
      }
      
      override protected function getMultiPlaceGameMode() : GameMode
      {
         return new GMMutableAnimalPlace(this.m_breedMetadata,m_animalType,m_isGift,m_cid,false,this.m_fromMarket);
      }
   }
}

