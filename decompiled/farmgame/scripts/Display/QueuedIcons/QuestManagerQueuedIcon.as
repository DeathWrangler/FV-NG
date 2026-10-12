package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Widgets.Windows.QuestManager.QuestManagerWindowV2;
   
   public class QuestManagerQueuedIcon extends QueuedIconWithArrow
   {
      
      public static const QUEST_MANAGER_ICON_NAME:String = "QuestManager";
      
      public static const QUEST_MANAGER_ICON_TYPE:String = "QuestManagerIcon";
      
      private static var hudIcon:QuestManagerQueuedIcon = null;
      
      private static var m_expiryArrowText:String = null;
      
      public function QuestManagerQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      public static function showHUDIcon() : void
      {
         if(hudIcon == null)
         {
            hudIcon = Global.hud.iconQueue.addIcon(QUEST_MANAGER_ICON_NAME,0,null,null,false) as QuestManagerQueuedIcon;
            if(hudIcon != null)
            {
               hudIcon.onAdd();
            }
         }
      }
      
      public function onAdd() : void
      {
         var newQuestsNamedPrereq:String = Global.flashHotParams["QUEST_MANAGER_NEW_QUESTS_EXPERIMENT"];
         if(PrerequisiteUtility.checkPrereqByName(newQuestsNamedPrereq) && Global.player.getActionCount(QuestManagerWindowV2.QUEST_MANAGER_V2_VIEWED) < Global.flashHotParams[QuestManagerWindowV2.QUEST_MANAGER_V2_VIEWED])
         {
            this.attachArrow(ArrowType.ARROWNEW);
         }
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs","QMNewQuests"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
               break;
            case ArrowType.ARROWEXPIRY:
               setArrowText(m_expiryArrowText);
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
      
      public function attachExpiryArrow(expiryArrowText:String) : void
      {
         m_expiryArrowText = expiryArrowText;
         this.attachArrow(ArrowType.ARROWEXPIRY);
      }
   }
}

