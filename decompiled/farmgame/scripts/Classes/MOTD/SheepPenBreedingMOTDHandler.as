package Classes.MOTD
{
   import Classes.util.ZLocUtils;
   
   public class SheepPenBreedingMOTDHandler extends ConstructionBuildingMOTDHandler
   {
      
      private static const DIALOG_ICON_URL:String = "assets/dialogs/FV_Support/FV_SheepPen/sheepBreeding_motd.png";
      
      private static const ITEM_NAME_FINISHED_SHEEPPEN:String = "xuk_sheep_pen_finished";
      
      private static const ITEM_NAME_CONSTRUCTION_SHEEPPEN:String = "xuk_sheep_pen";
      
      private static const ITEM_NAME_FINISHED_GIFT:String = "sheeppen_ram_quest0203";
      
      public function SheepPenBreedingMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function getDialogParameters(userFlow:int) : Object
      {
         var titleText:String = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Title");
         var bodyText:String = "";
         var buttonText:String = "";
         switch(userFlow)
         {
            case ConstructionBuildingMOTDHandler.USER_FLOW_COMPLETED_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_0_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_0_ButtonText");
               break;
            case ConstructionBuildingMOTDHandler.USER_FLOW_CONSTRUCT_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_1_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_1_ButtonText");
               break;
            case ConstructionBuildingMOTDHandler.USER_FLOW_CONSTRUCT_GIFTBOX:
            case ConstructionBuildingMOTDHandler.USER_FLOW_NO_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_2_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_sheeppen_finished_Flow_2_ButtonText");
         }
         return {
            "imageUrl":DIALOG_ICON_URL,
            "titleText":titleText,
            "bodyText":bodyText,
            "buttonText":buttonText
         };
      }
      
      override protected function getFinishedBuildingName() : String
      {
         return ITEM_NAME_FINISHED_SHEEPPEN;
      }
      
      override protected function getConstructionBuildingName() : String
      {
         return ITEM_NAME_CONSTRUCTION_SHEEPPEN;
      }
      
      override protected function getFinishedGiftName() : String
      {
         return ITEM_NAME_FINISHED_GIFT;
      }
   }
}

