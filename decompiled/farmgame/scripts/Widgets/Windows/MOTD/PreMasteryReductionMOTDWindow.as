package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Promotions.PostMasteryReductionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class PreMasteryReductionMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static const START_DATE:String = "Aug 31st 2015";
      
      protected var m_learnMoreLink:ZwButton;
      
      private var m_content:ZwFrame;
      
      public function PreMasteryReductionMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var content_mc:MovieClip = null;
         var bonus_mc:MovieClip = null;
         if(Boolean(m_window) && m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","preMasteryReduction_MOTD_accept"),onAccept));
            }
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","preMasteryReduction_MOTD_title")));
            }
            if(m_window.mainWindow.body1_tf)
            {
               addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","preMasteryReduction_MOTD_body1")));
            }
            if(m_window.mainWindow.content_mc)
            {
               addWidget(this.m_content = new ZwFrame(m_window.mainWindow.content_mc));
               content_mc = m_window.mainWindow.content_mc as MovieClip;
               if(content_mc.body1_tf)
               {
                  this.m_content.addWidget(new FarmTextField(content_mc.body1_tf,ZLocUtils.t("Dialogs","preMasteryReduction_MOTD_content_body_1")));
               }
               if(content_mc.body2_tf)
               {
                  this.m_content.addWidget(new FarmTextField(content_mc.body2_tf,ZLocUtils.t("Dialogs","preMasteryReduction_MOTD_content_body_2")));
               }
               content_mc.gotoAndPlay(1);
            }
            if(m_window.mainWindow.hasOwnProperty("knowmore_tf"))
            {
               this.m_learnMoreLink = addWidget(new ZwButton(m_window.mainWindow.knowmore_tf,this.onLernMoreLinkClick)) as ZwButton;
               this.m_learnMoreLink.element.useHandCursor = true;
               this.m_learnMoreLink.element.buttonMode = true;
               this.m_learnMoreLink.element.mouseChildren = false;
            }
            if(m_window.mainWindow.bonus_mc)
            {
               bonus_mc = m_window.mainWindow.bonus_mc as MovieClip;
               bonus_mc.visible = false;
            }
         }
      }
      
      private function onLernMoreLinkClick(event:Event) : void
      {
         navigateToURL(new URLRequest(PostMasteryReductionWindow.FAQ_LINK),"_blank");
      }
   }
}

