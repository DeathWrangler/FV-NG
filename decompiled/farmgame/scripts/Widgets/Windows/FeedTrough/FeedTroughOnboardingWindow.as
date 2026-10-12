package Widgets.Windows.FeedTrough
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   
   public class FeedTroughOnboardingWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_FeedTrough_Onboarding.swf";
      
      private const PROPERTIES_FILE:String = "Dialogs";
      
      public function FeedTroughOnboardingWindow()
      {
         super(ASSET_URL,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingTitle")));
         addWidget(new ZwTextField(m_window.header1_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepOneHeader")));
         addWidget(new ZwTextField(m_window.generic1_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepOneText")));
         addWidget(new ZwTextField(m_window.header2_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepTwoHeader")));
         addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepTwoText")));
         addWidget(new ZwTextField(m_window.header3_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepThreeHeader")));
         addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingStepThreeText")));
         addWidget(new ZwTextField(m_window.sidebar_tf,ZLocUtils.t(this.PROPERTIES_FILE,"FeedTroughOnboardingNewAnimalText")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t(this.PROPERTIES_FILE,"Okay"),onClose));
      }
   }
}

