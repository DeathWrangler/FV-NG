package Init.PostInitActionHandlers
{
   import Classes.CrossPromoDescriptor;
   import Classes.CrossPromoDescriptorManager;
   import Managers.ToasterManager;
   import Widgets.Windows.CrossPromo.CrossPromoDescriptorToasterWindow;
   
   public class CrossPromoToasterPostInitAction extends AbstractPostInitAction
   {
      
      protected var m_crossPromoDescriptor:CrossPromoDescriptor = null;
      
      public function CrossPromoToasterPostInitAction(crossPromoDescriptor:CrossPromoDescriptor, callback:Function = null)
      {
         this.m_crossPromoDescriptor = crossPromoDescriptor;
         super(callback);
      }
      
      override public function execute() : void
      {
         var seenFlag:Boolean = CrossPromoDescriptorManager.getToasterSeenFlag(this.m_crossPromoDescriptor);
         if(!seenFlag)
         {
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().addImmediate(new CrossPromoDescriptorToasterWindow(this.m_crossPromoDescriptor));
         }
         m_isFinished = true;
      }
   }
}

