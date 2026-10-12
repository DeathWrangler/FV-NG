package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.ToasterManager;
   import Widgets.Windows.Quests.QuestNPCVisitToasterWindow;
   
   public class ToastHelperAction extends QuestHelperAction
   {
      
      protected var m_assetUrl:String;
      
      protected var m_locId:String;
      
      public function ToastHelperAction(questName:String, locId:String, assetUrl:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_assetUrl = assetUrl;
         this.m_locId = locId;
      }
      
      override public function perform() : void
      {
         var message:String = ZLocUtils.t("Quests",this.m_locId);
         ToasterManager.getInstance().addImmediate(new QuestNPCVisitToasterWindow(this.m_assetUrl,message));
         super.perform();
      }
   }
}

