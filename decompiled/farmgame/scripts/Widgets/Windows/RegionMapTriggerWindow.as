package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class RegionMapTriggerWindow extends FarmWindow
   {
      
      public static const COMINGSOON_SEEN:String = "comingsoon_seen";
      
      private static const DIALOG_PREFIX:String = "comingSoonWindow";
      
      private var m_communityGoalsButton:FarmAnimatedTextButton;
      
      private var m_taskCountText:ZwTextField;
      
      private var m_featureName:String;
      
      public function RegionMapTriggerWindow(featureName:String = "billboard1", dialogPath:String = "assets/dialogs/Japan/R4Feature/FV_xjp_R4Feature_Billboard_01.swf")
      {
         super(dialogPath);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_body")),true);
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(new ZwTextField(m_window.body2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_body_two")),true);
         }
         if(m_window.hasOwnProperty("task_tf"))
         {
            this.m_taskCountText = new ZwTextField(m_window.task_tf,"");
            addWidget(this.m_taskCountText,true);
            this.m_taskCountText.text = "x" + BringBackWinterManager.getInstance(this.m_featureName).getSfCollectionCount(BringBackWinterManager.SF_PINK).toString();
         }
      }
      
      override protected function release() : void
      {
         if(this.m_communityGoalsButton)
         {
            this.m_communityGoalsButton = null;
         }
         if(this.m_taskCountText)
         {
            this.m_taskCountText = null;
         }
         super.release();
      }
   }
}

