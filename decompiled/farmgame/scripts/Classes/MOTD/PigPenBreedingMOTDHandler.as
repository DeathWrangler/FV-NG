package Classes.MOTD
{
   import Classes.util.ZLocUtils;
   
   public class PigPenBreedingMOTDHandler extends ConstructionBuildingMOTDHandler
   {
      
      private static const ONBOARD_DIALOG_URL:String = "assets/dialogs/FV_Support/FV_PigPen/pigBreeding_motd.png";
      
      private static const ITEM_NAME_FINISHED_PIGPEN:String = "pigpenv2_finished";
      
      private static const ITEM_NAME_CONSTRUCTION_PIGPEN:String = "pigpen";
      
      private static const ITEM_NAME_FINISHED_GIFT:String = "pigpen_male_light_green";
      
      public function PigPenBreedingMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function getDialogParameters(userFlow:int) : Object
      {
         var titleText:String = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Title");
         var bodyText:String = "";
         var buttonText:String = "";
         switch(userFlow)
         {
            case ConstructionBuildingMOTDHandler.USER_FLOW_COMPLETED_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_0_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_0_ButtonText");
               break;
            case ConstructionBuildingMOTDHandler.USER_FLOW_CONSTRUCT_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_1_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_1_ButtonText");
               break;
            case ConstructionBuildingMOTDHandler.USER_FLOW_CONSTRUCT_GIFTBOX:
            case ConstructionBuildingMOTDHandler.USER_FLOW_NO_BUILDING:
               bodyText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_2_Text");
               buttonText = ZLocUtils.t("Dialogs","MOTD_pigpenv2_finished_Flow_2_ButtonText");
         }
         return {
            "imageUrl":ONBOARD_DIALOG_URL,
            "titleText":titleText,
            "bodyText":bodyText,
            "buttonText":buttonText
         };
      }
      
      override protected function getFinishedBuildingName() : String
      {
         return ITEM_NAME_FINISHED_PIGPEN;
      }
      
      override protected function getConstructionBuildingName() : String
      {
         return ITEM_NAME_CONSTRUCTION_PIGPEN;
      }
      
      override protected function getFinishedGiftName() : String
      {
         return ITEM_NAME_FINISHED_GIFT;
      }
   }
}

