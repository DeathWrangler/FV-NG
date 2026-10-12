package Classes.consumables
{
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   
   public class CCoins extends Consumable
   {
      
      public function CCoins(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var status:String = null;
         var coins:int = getItem().coins;
         if(coins > 0)
         {
            Global.player.gold += coins;
            status = ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":Utilities.formatNumber(coins)});
            Global.player.avatar.displayStatus(status);
         }
      }
   }
}

