package Classes.Quest.helperactions
{
   import Classes.Constants.MFSConstants;
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import ZQuest.Init.QuestSettingsInit;
   
   public class AskForItemByRequestHelperAction extends ItemHelperAction
   {
      
      private const FEATURE_NAME:String = "questR4R";
      
      public function AskForItemByRequestHelperAction(questName:String, itemName:String)
      {
         super(questName,itemName);
      }
      
      override public function perform() : void
      {
         MFSRequestManager.getInstance().makeAskItemsRequest(this.FEATURE_NAME,itemName,"","",MFSConstants.SOURCE_DIALOG_CLICKED);
         var farmQuest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(m_questName) as FarmQuest;
         if(farmQuest)
         {
            FeatureTrackingManager.instance.sendR4R(farmQuest.chain);
         }
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_R4R_Button");
      }
   }
}

