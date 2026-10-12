package Widgets.Windows
{
   import Engine.Managers.StatsManager;
   import Managers.PumpkinPartyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PumpkinPartyInnovationTileUnlockwindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "PumpkinPartyInnovation";
      
      private var m_featureName:String;
      
      private var m_tokens_collected:int;
      
      private var m_tileName:String;
      
      private var m_tileFriendlyName:String;
      
      private var m_size_mc:MovieClip;
      
      private var m_land_reward_brief_tf:ZwTextField;
      
      private var m_land_reward_title_tf:ZwTextField;
      
      private var m_land_reward_okay_bt:FarmAnimatedTextButton;
      
      private var m_land_reward_icon_mc:FarmIcon;
      
      private var m_close_bt:SimpleButton;
      
      public function PumpkinPartyInnovationTileUnlockwindow(featureName:String = "PumpkinPartyInnovation", assetUrl:String = null, tokensCollected:int = 0, tileName:String = "", tileFriendlyName:String = "")
      {
         this.m_featureName = featureName;
         this.m_tokens_collected = tokensCollected;
         this.m_tileName = tileName;
         this.m_tileFriendlyName = tileFriendlyName;
         super(featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardTitle:String = null;
         var rewardBrief:String = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window)
         {
            if(m_window.hasOwnProperty("size_mc"))
            {
               this.m_size_mc = m_window["size_mc"] as MovieClip;
               this.m_size_mc.visible = true;
            }
            if(m_window.hasOwnProperty("landrewardheader_tf"))
            {
               rewardTitle = this.m_tileFriendlyName + " Available!";
               this.m_land_reward_title_tf = new ZwTextField(m_window["landrewardheader_tf"],rewardTitle);
               this.m_land_reward_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("landrewardbrief_tf"))
            {
               rewardBrief = "Congrats! You have collected " + this.m_tokens_collected + " Escape Tokens and can unlock " + this.m_tileFriendlyName + ". Click here to unlock!";
               this.m_land_reward_brief_tf = new ZwTextField(m_window["landrewardbrief_tf"],rewardBrief);
               this.m_land_reward_brief_tf.visible = true;
            }
            if(m_window.hasOwnProperty("landrewardok_bt"))
            {
               this.m_land_reward_okay_bt = new FarmAnimatedTextButton(m_window["landrewardok_bt"],"Unlock!",this.onUnlockButtonClick);
               this.m_land_reward_okay_bt.visible = true;
            }
            if(m_window.hasOwnProperty("specialfertilizer_icon"))
            {
               this.m_land_reward_icon_mc = new FarmIcon(m_window["specialfertilizer_icon"]);
               this.m_land_reward_icon_mc.visible = true;
            }
            if(m_window.hasOwnProperty("close_bt"))
            {
               this.m_close_bt = new SimpleButton(m_window["close_bt"]);
               this.m_close_bt.visible = false;
            }
         }
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : PumpkinPartyInnovationManager
      {
         return PumpkinPartyInnovationManager.getInstance();
      }
      
      private function onUnlockButtonClick(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"TileAvailable_Dialog",this.m_tileFriendlyName,"Unlock");
         this.manager.unlockCurrentTile();
         this.close();
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.close();
         }
         this.manager.highlightTile(this.m_tileName);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(Boolean(this.manager) && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
   }
}

