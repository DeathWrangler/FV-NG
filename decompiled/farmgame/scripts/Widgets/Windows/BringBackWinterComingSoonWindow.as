package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Managers.CommunityGoalsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BringBackWinterComingSoonWindow extends FarmWindow
   {
      
      public static const COMINGSOON_SEEN:String = "comingsoon_seen";
      
      private static const DIALOG_PREFIX:String = "comingSoonWindow";
      
      private var m_communityGoalsButton:FarmAnimatedTextButton;
      
      private var m_taskCountText:ZwTextField;
      
      private var m_featureName:String;
      
      protected var m_learnMore_mc:FarmAnimatedButton;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      public function BringBackWinterComingSoonWindow(featureName:String = "bring_back_christmas", dialogPath:String = "assets/dialogs/FV_Easter_MOTD.swf")
      {
         super(dialogPath);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,DIALOG_PREFIX + "_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,DIALOG_PREFIX + "_body")),true);
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(new ZwTextField(m_window.body2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,DIALOG_PREFIX + "_body_two")),true);
         }
         if(m_window.hasOwnProperty("aceept_bt"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.aceept_bt,"Can\'t Wait",this.onShareButtonClicked));
         }
         if(m_window.hasOwnProperty("goals_bt"))
         {
            addWidget(this.m_communityGoalsButton = new FarmAnimatedTextButton(m_window.goals_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,DIALOG_PREFIX + "_goals_bt"),this.onCommunityGoalsButtonClick),true);
            this.m_communityGoalsButton.visible = CommunityGoalsManager.getInstance().getActiveTask() ? true : false;
         }
         if(m_window.hasOwnProperty("task_tf"))
         {
            this.m_taskCountText = new ZwTextField(m_window.task_tf,"");
            addWidget(this.m_taskCountText,true);
            this.m_taskCountText.text = "x" + BringBackWinterManager.getInstance(this.m_featureName).getSfCollectionCount(BringBackWinterManager.SF_PINK).toString();
         }
         if(m_window.hasOwnProperty("learnMore_mc"))
         {
            this.m_learnMore_mc = addWidget(new FarmAnimatedTextButton(m_window.learnMore_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LearnMore"),this.openUrl),true) as FarmAnimatedButton;
         }
         Global.player.setSeenFlag(COMINGSOON_SEEN);
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
      
      public function onShareButtonClicked(event:Event = null) : void
      {
         close();
      }
      
      private function onCommunityGoalsButtonClick(event:Event) : void
      {
         if(this.m_communityGoalsButton)
         {
            this.close();
            CommunityGoalsManager.getInstance().displayDialog();
         }
      }
      
      private function openUrl(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","MOTD_MerryMarshall_Link_URL")),"_blank");
      }
   }
}

