package Classes.consumables
{
   import Classes.TargetedConsumable;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   
   public class CSlotMachineToken extends TargetedConsumable
   {
      
      public function CSlotMachineToken(itemName:String, targetObjectId:Number)
      {
         super(itemName,targetObjectId);
      }
      
      override public function onUse() : void
      {
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      override public function onFailedPerform() : void
      {
         FarmStatsManager.count(getItemName(),"token_fail");
         UI.displayMessage(ZLocUtils.t("Dialogs","SlotMachineTokenInvalid"),GenericPopup.TYPE_OK,null,"token_invalid",true);
      }
   }
}

