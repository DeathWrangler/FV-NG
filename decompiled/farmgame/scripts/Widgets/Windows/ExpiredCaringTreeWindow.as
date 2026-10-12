package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class ExpiredCaringTreeWindow extends FarmWindow
   {
      
      protected var m_featureBuilding:FeatureBuilding;
      
      public function ExpiredCaringTreeWindow(building:FeatureBuilding)
      {
         this.m_featureBuilding = building;
         var dialogConfig:Object = this.m_featureBuilding.getDialogConfig();
         if(dialogConfig == null)
         {
            dialogConfig = this.m_featureBuilding.getItem().getDialogConfig("storage");
         }
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path,true,true);
         }
         else
         {
            GlobalEngine.assert(false,"building is missing a dialog config");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","ExpiredCaringTreeTitle")));
            }
            if(m_window.hasOwnProperty("copy_tf"))
            {
               addWidget(new ZwTextField(m_window["copy_tf"],ZLocUtils.t("Dialogs","ExpiredCaringTreeSubtitle")));
            }
            if(m_window.hasOwnProperty("unlocked_tf"))
            {
               addWidget(new ZwTextField(m_window["unlocked_tf"],ZLocUtils.t("Dialogs","ExpiredCaringTreeDescription")));
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t("Dialogs","ExpiredCaringTreeAcceptButtonText"),onClose));
            }
         }
      }
   }
}

