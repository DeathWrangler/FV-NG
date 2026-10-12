package Classes.Idle
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.ActionDrivenManager;
   import Managers.ToasterManager;
   import Widgets.Windows.ActionDrivenWindow;
   import Widgets.Windows.GenericSingleButtonTitleToaster;
   
   public class ActionDrivenIdleTask extends PrereqDrivenIdleTask
   {
      
      public function ActionDrivenIdleTask(featureName:String)
      {
         super(featureName);
         m_displaysPopup = true;
      }
      
      override public function fire() : void
      {
         var assetUrl:String = ActionDrivenManager.getInstance(m_featureName).getConstantsStringWithKey("toasterAssetPath");
         var title:String = ZLocUtils.t(ActionDrivenWindow.ZLOC_PACKAGE_DIALOGS,m_featureName + "_toaster_title");
         var body:String = ZLocUtils.t(ActionDrivenWindow.ZLOC_PACKAGE_DIALOGS,m_featureName + "_toaster_body");
         var buttonText:String = ZLocUtils.t(ActionDrivenWindow.ZLOC_PACKAGE_DIALOGS,m_featureName + "_toaster_button_text");
         ToasterManager.getInstance().add(new GenericSingleButtonTitleToaster(assetUrl,title,body,buttonText,FarmGameUtil.applyPartialStatic(ActionDrivenManager.showStaticWithObj,[{"featureName":m_featureName}]),null,m_featureName));
      }
   }
}

