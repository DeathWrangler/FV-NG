package Classes.Quest.helperactions
{
   import Display.Quests.QuestProgressDialog;
   
   public class QuestHelperAction
   {
      
      protected var m_questName:String = null;
      
      protected var m_progressDialog:QuestProgressDialog = null;
      
      protected var m_shouldCloseOnPerform:Boolean = false;
      
      protected var m_callback:Function = null;
      
      public function QuestHelperAction(questName:String)
      {
         super();
         this.m_questName = questName;
      }
      
      public function canPerform() : Boolean
      {
         return true;
      }
      
      public function perform() : void
      {
         if(this.m_shouldCloseOnPerform == true && this.m_progressDialog != null)
         {
            this.m_progressDialog.destroy();
         }
      }
      
      public function get readableText() : String
      {
         return "";
      }
      
      public function set progressDialog(progressDialog:QuestProgressDialog) : void
      {
         this.m_progressDialog = progressDialog;
      }
      
      public function set callback(callback:Function) : void
      {
         this.m_callback = callback;
      }
   }
}

