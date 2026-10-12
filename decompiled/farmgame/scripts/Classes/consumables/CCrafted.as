package Classes.consumables
{
   import Classes.Consumable;
   
   public class CCrafted extends Consumable
   {
      
      public function CCrafted(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
   }
}

