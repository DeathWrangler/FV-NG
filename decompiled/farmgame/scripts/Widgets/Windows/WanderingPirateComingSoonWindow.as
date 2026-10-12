package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class WanderingPirateComingSoonWindow extends FarmWindow
   {
      
      private static const RARE_STRING:String = "rare";
      
      private static const ICON_SIZE:int = 200;
      
      private var m_titleTf:FarmTextField;
      
      private var m_bodyTf:FarmTextField;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardmc:MovieClip = null;
      
      private var m_rewardRarity:String;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      public function WanderingPirateComingSoonWindow(assetPath:String = "assets/dialogs/WP_LostCities2018/FV_WPLostCities2018_OffBoard.swf")
      {
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = addWidget(new FarmTextField(m_window.title_tf as TextField,ZLocUtils.t("Dialogs","wp_lostcities_title"),true)) as FarmTextField;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            this.m_bodyTf = addWidget(new FarmTextField(m_window.body_tf as TextField,ZLocUtils.t("Dialogs","wp_lostcities_body"),true)) as FarmTextField;
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,"Aye Aye, Cap’n!",this.onShareButtonClicked));
         }
      }
      
      public function onShareButtonClicked(event:Event = null) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_shareButton = null;
         super.release();
      }
   }
}

