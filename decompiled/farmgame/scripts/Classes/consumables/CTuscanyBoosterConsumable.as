package Classes.consumables
{
   import Classes.Consumable;
   import Classes.Quest.PrerequisiteUtility;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.TuscanyInnovationManager;
   
   public class CTuscanyBoosterConsumable extends Consumable
   {
      
      public function CTuscanyBoosterConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tuscany_innovation_enabled");
         var message:String = "";
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            message = "You will be able to use this Booster ticket only once you earn one of the Bonus Rewards in The Grape Escape!";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"TuscanyBossterDisabled",true);
         }
         else if(TuscanyInnovationManager.getInstance().overAllProgressLevel() < 0)
         {
            message = "Sorry, Farmer. You will not be able to use this since you have not won the Bonus Reward for which you can use this Winery Booster on.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"TuscanyBossterDisabled",true);
         }
         else if(TuscanyInnovationManager.getInstance().isBoosterApplied())
         {
            message = "You have already applied a booster on your bonus reward. Harvest the bonus to apply the booster again.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"TuscanyBossterDisabled",true);
         }
         else
         {
            TuscanyInnovationManager.getInstance().HighlightBonusBuilding();
         }
      }
   }
}

