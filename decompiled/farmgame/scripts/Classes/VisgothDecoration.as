package Classes
{
   import Managers.CapitalOnePromoManager;
   
   public class VisgothDecoration extends BuffDecoration
   {
      
      public function VisgothDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function showPlacementDialog() : void
      {
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         CapitalOnePromoManager.countStatuePlaced();
         Global.player.setSeenFlag(CapitalOnePromoManager.ITEM_PLACED,true);
         onPlacedFirstTime();
      }
   }
}

