package Widgets.Windows
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CoOpFinalGrantReward extends FarmWindow
   {
      
      public static const SERVICE_NAME:String = "GuildService";
      
      private var m_backgroundMc:MovieClip;
      
      private var m_giftbox:MovieClip;
      
      private var m_acceptBt:FarmAnimatedTextButton;
      
      private var m_reward:MovieClip;
      
      public function CoOpFinalGrantReward(assetPath:String = "")
      {
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               m_window["title_tf"].visible = true;
               m_window["title_tf"].text = "Farmers Clan";
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               m_window["subtext1_tf"].visible = true;
               m_window["subtext1_tf"].text = "Farmers Clan has ended. Thanks for participating!";
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               m_window["subtext2_tf"].visible = true;
               m_window["subtext2_tf"].text = "Here’s the reward for your valuable contribution!";
            }
            if(m_window.hasOwnProperty("background_mc"))
            {
               this.m_backgroundMc = m_window["background_mc"] as MovieClip;
               this.m_backgroundMc.visible = true;
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_giftbox = m_window["giftbox_mc"] as MovieClip;
               this.m_giftbox.visible = true;
            }
            if(m_window.hasOwnProperty("reward_mc"))
            {
               this.m_reward = m_window["reward_mc"] as MovieClip;
               this.m_reward.visible = true;
               this.m_reward.play();
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(this.m_acceptBt = new FarmAnimatedTextButton(m_window["accept_bt"],"Thanks!",this.onAccept));
               this.m_acceptBt.visible = true;
            }
            Global.player.addGift("horse_homecoming",null,1);
            Global.player.addGift("consume_unwither",null,2);
            Global.player.addGift("consume_organic_fertilizer",null,2);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantFinalCoOpReward",null,["FVGuild"]),true);
         }
      }
      
      private function onAccept(event:Event) : void
      {
         super.close();
      }
   }
}

