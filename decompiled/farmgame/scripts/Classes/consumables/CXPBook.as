package Classes.consumables
{
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   
   public class CXPBook extends Consumable
   {
      
      public function CXPBook(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var status:String = null;
         var currentLevel:int = Global.player.level;
         var nextLevel:int = ++currentLevel;
         var currentXP:int = Global.player.xp;
         var neededXP:int = Global.farmGameSettingsManager.getXPForLevel(nextLevel) - currentXP;
         if(neededXP > 0)
         {
            Global.player.calculateAndAddXp(neededXP,false);
            status = ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":Utilities.formatNumber(neededXP)});
            Global.player.avatar.displayStatus(status);
         }
      }
   }
}

