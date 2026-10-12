package Widgets.Windows.MOTD
{
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.XMASInnovationWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public class AntiqueMuseumV2MOTDWindow extends FarmWindow
   {
      
      public static const SERVICE_CLASS:String = "AntiqueMuseumV2MOTDService";
      
      public static const REWARD_GRANTED_FLAG:String = "AntiqueMuseumV2MOTD_GrantFlag";
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      private const TITLE_TF:String = "motdtittle_tf";
      
      private const STORY_MC:String = "story_mc";
      
      private const BODY_TF:String = "body_tf";
      
      private const BACK_MC:String = "back_mc";
      
      private const COUNT1_TF:String = "count1_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const COLLECTION_MC:Array = ["collection0_mc","collection1_mc","collection2_mc"];
      
      private const TEXT_TITLE:String = "_ChristmasUIWindow_Title";
      
      private const TEXT_BODY:String = "_ChristmasUIWindow_Body";
      
      private const TEXT_BODY2:String = "_ChristmasUIWindow_Body2";
      
      private const ANTIQUE_MUSEUM_BUILDING:String = "antiquemuseum";
      
      private var m_featureName:String = null;
      
      private var m_accept_bt:FarmButton;
      
      private var m_storyMC:MovieClip;
      
      private var m_frameNum:int = 1;
      
      private var m_mainWindow:XMASInnovationWindow;
      
      private var m_endDate:String;
      
      private var m_antiqueMuseumManager:AntiqueMuseumV2Manager;
      
      private var m_timer:Timer;
      
      public function AntiqueMuseumV2MOTDWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "NATURAL HISTORY MUSEUM";
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Wow!",this.onOkayClick);
            this.m_accept_bt.visible = true;
         }
         if(m_window.hasOwnProperty(this.STORY_MC))
         {
            this.m_storyMC = m_window[this.STORY_MC] as MovieClip;
            this.m_storyMC.visible = true;
         }
      }
      
      public function onOkayClick(e:Event) : *
      {
         if(!Global.player.getSeenFlag("AntiqueMuseumV2_FictionSeen"))
         {
            Global.player.setSeenFlag("AntiqueMuseumV2_FictionSeen");
         }
         if(this.m_frameNum >= 3)
         {
            super.close();
            this.m_frameNum = 0;
            AntiqueMuseumV2Manager.getInstance(AntiqueMuseumV2Manager.FEATURE_NAME).showMainWindow();
         }
         else
         {
            if(this.m_storyMC)
            {
               this.m_storyMC.gotoAndPlay(this.m_frameNum);
            }
            ++this.m_frameNum;
            if(this.m_frameNum == 2)
            {
               this.m_accept_bt.element.generic_tf.text = "Really?";
            }
            else if(this.m_frameNum == 3)
            {
               this.m_accept_bt.element.generic_tf.text = "Let\'s Go!";
            }
         }
      }
   }
}

