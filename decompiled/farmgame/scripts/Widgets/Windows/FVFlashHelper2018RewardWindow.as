package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class FVFlashHelper2018RewardWindow extends FarmWindow
   {
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function FVFlashHelper2018RewardWindow(dialogPath:String)
      {
         super(dialogPath);
      }
      
      public static function launchPluginRewardWindow() : void
      {
         UI.displayPopup(new FVFlashHelper2018RewardWindow("assets/dialogs/ChromePlugin2018/FV_ChromePlugin2018_RewardDialog.swf"),false);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_installed_title")));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_installed_text")));
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(new ZwTextField(m_window["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_installed_subtext")));
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"limbo1PaidGiftingRecipient_accept"),this.onAccept));
         }
      }
      
      private function onAccept(evt:MouseEvent) : void
      {
         close();
      }
   }
}

