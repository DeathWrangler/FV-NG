package Widgets.Windows
{
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class FarmFeedIssueWindow extends FarmWindow
   {
      
      public static const ASSET_DETAILS:String = "assets/dialogs/FV_FeedPopUp.swf";
      
      public static const feedResultFail:String = "fail";
      
      public static const feedResultSuccess:String = "success";
      
      private var m_windowTitle:String = "";
      
      private var m_windowMessage:String = "";
      
      private var m_reference:String = "";
      
      private var m_externalReference:String = "";
      
      public function FarmFeedIssueWindow(windowTitle:String = "", windowMessage:String = "", reference:String = "", externalReference:String = "")
      {
         super(ASSET_DETAILS,true);
         this.m_windowTitle = windowTitle;
         this.m_windowMessage = windowMessage;
         this.m_reference = reference;
         this.m_externalReference = externalReference;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.accept_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("FarmGame","Report"),this.acceptPrompt));
         }
         if(m_window.cancel_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","FarmFeedIssueWindow_noReloadMessage"),this.cancelPrompt));
         }
         if(m_window.link_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.link_bt,ZLocUtils.t("Dialogs","FarmFeedIssueWindow_learnMoreButtonText"),this.learnMorePrompt));
         }
         if(m_window.link_tf)
         {
            addWidget(new ZwTextField(m_window.link_tf,ZLocUtils.t("Dialogs","FarmFeedIssueWindow_learnMoreMessage"),true));
         }
         if(m_window.title_tf)
         {
            if(this.m_windowTitle == "")
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","FarmFeedIssueWindowDefault_Title")));
            }
            else
            {
               addWidget(new ZwTextField(m_window.title_tf,this.m_windowTitle));
            }
         }
         if(m_window.popupBox_tf)
         {
            if(this.m_windowMessage == "")
            {
               addWidget(new ZwTextField(m_window.popupBox_tf,ZLocUtils.t("Dialogs","FarmFeedIssueWindowDefault_mainMessage")));
            }
            else
            {
               addWidget(new ZwTextField(m_window.popupBox_tf,this.m_windowMessage));
            }
         }
         StatsManager.count("jsbuster","info","FarmFeedIssueWindow","postLoadComplete","functionCalled",this.m_reference);
      }
      
      private function acceptPrompt(event:Event) : void
      {
         ExternalUtil.instance.call("onClickSendReportOnFeedIssueWindow",this.m_reference,this.m_externalReference);
         StatsManager.count("jsbuster","info","FarmFeedIssueWindow","makeUserEnvInfoReport","functionCalled",this.m_reference);
         super.onClose(event);
      }
      
      private function cancelPrompt(event:Event) : void
      {
         StatsManager.count("jsbuster","info","FarmFeedIssueWindow","cancelPrompt","functionCalled",this.m_reference);
         super.onClose(event);
      }
      
      private function learnMorePrompt(event:Event) : void
      {
         UI.showMessage(ZLocUtils.t("Dialogs","FarmFeedIssueWindow_details"));
         StatsManager.count("jsbuster","info","FarmFeedIssueWindow","learnMorePrompt","functionCalled",this.m_reference);
      }
      
      override protected function onClose(event:Event) : void
      {
         ExternalUtil.instance.call("onClickCloseOnFarmFeedIssueWindow");
         StatsManager.count("jsbuster","info","FarmFeedIssueWindow","onClose","functionCalled",this.m_reference);
         super.close();
      }
   }
}

