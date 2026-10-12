package Classes.consumables
{
   import Classes.Consumable;
   import Classes.Quest.PrerequisiteUtility;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.RussiaInnovationManager;
   
   public class CRussiaBoosterConsumable extends Consumable
   {
      
      public function CRussiaBoosterConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("russia_innovation_enabled");
         var message:String = "";
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            message = "You will be able to use this Power Booster only once you earn one of the Bonus Rewards in The Hammer Whammer!\n!";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"RussiaBossterDisabled",true);
         }
         else if(RussiaInnovationManager.getInstance().overAllProgressLevel() < 0)
         {
            message = "Sorry, Farmer. You will not be able to use this since you have not won the Bonus Reward for which you can use this Power Booster on.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"RussiaBossterDisabled",true);
         }
         else if(RussiaInnovationManager.getInstance().isBoosterApplied())
         {
            message = "You have already applied a Power Booster on your bonus reward. Harvest the bonus to apply the booster again.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"RussiaBossterDisabled",true);
         }
         else
         {
            RussiaInnovationManager.getInstance().HighlightBonusBuilding();
         }
      }
   }
}

