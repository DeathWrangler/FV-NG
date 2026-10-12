package Init.PostInitActionHandlers
{
   import Managers.ToasterManager;
   import Widgets.Windows.ToasterWindow;
   
   public class PostInitToaster extends AbstractPostInitAction
   {
      
      protected var m_toaster:ToasterWindow = null;
      
      public function PostInitToaster(toaster:ToasterWindow)
      {
         super(null);
         this.m_toaster = toaster;
      }
      
      override public function execute() : void
      {
         if(this.m_toaster)
         {
            ToasterManager.getInstance().add(this.m_toaster);
         }
         m_isFinished = true;
      }
   }
}

