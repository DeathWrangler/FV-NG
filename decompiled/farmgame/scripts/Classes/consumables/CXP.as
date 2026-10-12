package Classes.consumables
{
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   
   public class CXP extends Consumable
   {
      
      public function CXP(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var status:String = null;
         var xp:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            xp = getItem().getIntFromDataSource("xp");
         }
         else
         {
            xp = int(getItem().xml.xp);
         }
         if(xp > 0)
         {
            xp = Global.player.calculateAndAddXp(xp);
            status = ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":Utilities.formatNumber(xp)});
            Global.player.avatar.displayStatus(status);
         }
      }
   }
}

