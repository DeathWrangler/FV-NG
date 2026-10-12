package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class CombineOnboardingWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_combine_onboarding.swf";
      
      public static const SEEN_FLAG:String = "FirstCombine";
      
      public function CombineOnboardingWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CombineOnboarding_title")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","CombineOnboarding_subtitle")));
         addWidget(new ZwTextField(m_window.leftHead_tf,ZLocUtils.t("Dialogs","CombineOnboarding_harvest")));
         addWidget(new ZwTextField(m_window.leftBody_tf,ZLocUtils.t("Dialogs","CombineOnboarding_harvestBody")));
         addWidget(new ZwTextField(m_window.centerHead_tf,ZLocUtils.t("Dialogs","CombineOnboarding_plow")));
         addWidget(new ZwTextField(m_window.centerBody_tf,ZLocUtils.t("Dialogs","CombineOnboarding_plowBody")));
         addWidget(new ZwTextField(m_window.rightHead_tf,ZLocUtils.t("Dialogs","CombineOnboarding_plant")));
         addWidget(new ZwTextField(m_window.rightBody_tf,ZLocUtils.t("Dialogs","CombineOnboarding_plantBody")));
         addWidget(new ZwTextField(m_window.cta_tf,ZLocUtils.t("Dialogs","CombineOnboarding_pickSeeds")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","CombineOnboarding_acceptButton"),this.onClose));
      }
      
      override protected function onClose(event:Event) : void
      {
         Global.player.setSeenFlag(SEEN_FLAG);
         super.onClose(event);
      }
   }
}

