package Classes.consumables
{
   import Classes.Pet;
   import Classes.TargetedConsumable;
   
   public class CPetsKibble extends TargetedConsumable
   {
      
      public function CPetsKibble(itemName:String, targetObjectId:Number)
      {
         super(itemName,targetObjectId);
      }
      
      override public function onUse() : void
      {
         var pet:Pet = Global.world.getObjectById(m_targetObjectId) as Pet;
         if(pet)
         {
            pet.onFed();
         }
      }
   }
}

