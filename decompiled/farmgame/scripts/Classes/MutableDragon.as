package Classes
{
   import Classes.DragonBreeding.MutableDragonState;
   import Managers.DragonBreedingManager;
   
   public class MutableDragon extends Animal
   {
      
      protected static const DEFAULT_PATTERN_TYPE:String = "a";
      
      public static const SERVICE_CLASS:String = "DragonBreedingService";
      
      protected var m_assetName:String = "";
      
      protected var m_primaryHSV:Array = [];
      
      protected var m_secondaryHSV:Array = [];
      
      protected var m_lastTime:int;
      
      private var m_mutableAnimalState:MutableDragonState = null;
      
      private const ACTION_UPDATE_COUNT:String = "onUpdateDragon";
      
      private var m_featureName:String = "dragon_pen_finished";
      
      public function MutableDragon(animalType:String = null, metadata:String = null)
      {
         super(animalType);
      }
      
      public function setMutableAnimalStateFromMetaData(metadata:String) : void
      {
         this.m_mutableAnimalState = MutableDragonState.createFromPhpString("",metadata);
         this.setAnimalState();
      }
      
      public function setMutableAnimalState(mutableAnimalState:MutableDragonState) : void
      {
         this.m_mutableAnimalState = mutableAnimalState;
         this.setAnimalState();
      }
      
      protected function setAnimalState() : void
      {
      }
      
      public function getPackedMutableState() : String
      {
         var value:String = "";
         if(this.m_mutableAnimalState != null)
         {
            value = this.m_mutableAnimalState.getPackedMutableState();
         }
         return value;
      }
      
      override public function getMetadata() : Object
      {
         return this.getPackedMutableState();
      }
      
      override public function setMetadata(value:Object) : void
      {
         this.setMutableAnimalStateFromMetaData(String(value));
      }
      
      override public function cleanUp() : void
      {
         this.m_mutableAnimalState = null;
      }
      
      override public function onFinishPlace(result:Object = null) : void
      {
         super.onFinishPlace(result);
         DragonBreedingManager.getInstance(this.m_featureName).updateParentDragonItemCount(m_item.code);
         DragonBreedingManager.getInstance(this.m_featureName).openDragonBreedingUI();
      }
      
      private function onUpdateDragonCountComplete(result:Object) : void
      {
         var resObj:Object = null;
         if(result)
         {
            resObj = result;
            DragonBreedingManager.getInstance(this.m_featureName).openDragonBreedingUI();
         }
      }
      
      override public function allowDelete() : Boolean
      {
         return false;
      }
   }
}

