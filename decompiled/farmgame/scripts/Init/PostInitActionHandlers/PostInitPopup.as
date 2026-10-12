package Init.PostInitActionHandlers
{
   import Display.Dialog;
   import Display.UI;
   
   public class PostInitPopup extends AbstractPostInitAction
   {
      
      private var m_dialog:Dialog;
      
      public function PostInitPopup(dialog:Dialog, callback:Function = null)
      {
         super(callback);
         this.m_dialog = dialog;
      }
      
      override public function execute() : void
      {
         if(this.m_dialog)
         {
            UI.displayPopup(this.m_dialog);
         }
         m_isFinished = true;
      }
   }
}

