package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   
   public class StoryBookMOTDWindow extends CheckRequireOnShowMOTDWindow
   {
      
      private var m_leftArrowButton:FarmButton;
      
      private var m_rightArrowButton:FarmButton;
      
      private var m_chapterIcon:FarmIcon;
      
      public function StoryBookMOTDWindow()
      {
         super();
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var bodyText:String = null;
         if(Boolean(m_window) && Boolean(m_window.intro_mc))
         {
            addWidget(new ZwBaseWidget(m_window.intro_mc));
            if(m_window.intro_mc.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.intro_mc.accept_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),onAccept));
            }
            if(m_window.intro_mc.title_tf)
            {
               titleText = ZLocUtils.t_pk(m_currentMOTD["title"]);
               if(titleText != "")
               {
                  addWidget(new FarmTextField(m_window.intro_mc.title_tf,titleText));
               }
            }
            if(m_window.intro_mc.description_tf)
            {
               bodyText = ZLocUtils.t_pk(m_currentMOTD["text"]);
               if(bodyText != "")
               {
                  addWidget(new FarmTextField(m_window.intro_mc.description_tf,bodyText));
               }
            }
            if(m_window.intro_mc.icon_mc != null)
            {
               this.m_chapterIcon = addWidget(new FarmIcon(m_window.intro_mc.icon_mc)) as FarmIcon;
               this.loadChapterIcon(m_currentMOTD["chapterIcon"]);
            }
            if(m_window.intro_mc.leftArrow_bt)
            {
               this.m_leftArrowButton = new FarmButton(m_window.intro_mc.leftArrow_bt);
               this.m_leftArrowButton.visible = false;
            }
            if(m_window.intro_mc.rightArrow_bt)
            {
               this.m_rightArrowButton = new FarmButton(m_window.intro_mc.rightArrow_bt);
               this.m_rightArrowButton.visible = false;
            }
         }
      }
      
      private function loadChapterIcon(iconUrl:String) : void
      {
         if(iconUrl != "")
         {
            this.m_chapterIcon.loadIcon(Global.getAssetURL(iconUrl));
         }
      }
   }
}

