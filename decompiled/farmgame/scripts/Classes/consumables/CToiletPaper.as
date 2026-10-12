package Classes.consumables
{
   import Classes.TargetedConsumable;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   
   public class CToiletPaper extends TargetedConsumable
   {
      
      public function CToiletPaper(itemName:String, targetObjectId:Number)
      {
         super(itemName,targetObjectId);
      }
      
      override public function onUse() : void
      {
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      override public function onFailedPerform() : void
      {
         FarmStatsManager.count("toiletpaper","toiletpaper_gift_fail");
         UI.displayMessage(ZLocUtils.t("Dialogs","ToiletPaperInvalid"),GenericPopup.TYPE_OK,null,"unwither_invalid",true);
      }
      
      override public function canUse() : Boolean
      {
         return Global.worldManager.isVisiting();
      }
   }
}

