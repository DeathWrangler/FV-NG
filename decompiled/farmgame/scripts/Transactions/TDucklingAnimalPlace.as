package Transactions
{
   import Classes.DucklingAnimal;
   import Display.UI;
   
   public class TDucklingAnimalPlace extends TAnimalPlace
   {
      
      public function TDucklingAnimalPlace(animal:DucklingAnimal, isGift:Boolean = false, containerId:Number = 0)
      {
         super(animal,isGift,containerId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var duckling:DucklingAnimal = null;
         super.onComplete(result);
         if(this.m_rawResult.extraData.ducklingGameId)
         {
            duckling = this.m_object as DucklingAnimal;
            if(duckling)
            {
               duckling.ducklingGameId = this.m_rawResult.extraData.ducklingGameId;
            }
            if(duckling.transformEnabled && duckling.ducklingGameId >= 0)
            {
               UI.displayDuckGameWindow(this.m_rawResult.extraData.ducklingGameId,this.m_object.getId(),duckling.getItemName());
            }
            else
            {
               duckling.keepForever();
            }
         }
      }
   }
}

