package Classes.consumables
{
   import Classes.Animal;
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   
   public class CAnimalInstagrow extends Consumable
   {
      
      public function CAnimalInstagrow(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var animal:Animal = null;
         var errorDialogParams:Array = null;
         var result:Boolean = false;
         var animals:Array = Global.world.getObjectsByClass(Animal);
         for(var animalIdx:int = 0; animalIdx < animals.length; animalIdx++)
         {
            animal = animals[animalIdx] as Animal;
            if(animal.isPlaced() && !animal.isHarvestable())
            {
               result = true;
            }
         }
         if(!result)
         {
            errorDialogParams = [m_item.getImageByName("icon",false),ZLocUtils.t("Dialogs","AnimalInstagrow_Cannot_Use",{"item":ZLocUtils.tk_pk(m_item.friendlyName)})];
            UI.displayPopup(new DataDrivenOkayPopup("MotdNormal",errorDialogParams));
         }
         return result;
      }
      
      override public function onUse() : void
      {
         var animal:Animal = null;
         var animals:Array = Global.world.getObjectsByClass(Animal);
         for(var animalIdx:int = 0; animalIdx < animals.length; animalIdx++)
         {
            animal = animals[animalIdx] as Animal;
            if(animal.isPlaced() || animal.isGrown())
            {
               animal.setFullGrown();
            }
         }
      }
   }
}

