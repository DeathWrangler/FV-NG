package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.PunchCardFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class PunchCardFeatureRewardPopup extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "PunchCard";
      
      private var m_featureName:String = null;
      
      private var m_header_tf:TextField;
      
      private var m_subheader_tf:TextField;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_rewardicon_mc:FarmIcon;
      
      private var m_rewardItem:FarmItem;
      
      public function PunchCardFeatureRewardPopup(featureName:String = "PunchCard", assetUrl:String = null, rewardItem:FarmItem = null)
      {
         this.m_featureName = featureName;
         this.m_rewardItem = rewardItem;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("header_tf"))
         {
            this.m_header_tf = TextField(m_window["header_tf"]);
            this.m_header_tf.text = "HURRAY!";
            this.m_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("subheadeer_tf"))
         {
            this.m_subheader_tf = TextField(m_window["subheadeer_tf"]);
            if(this.m_rewardItem)
            {
               this.m_subheader_tf.text = "There\'s a punch on your Ticket!\nYou have won these rewards!";
            }
            this.m_subheader_tf.visible = true;
         }
         if(m_window.hasOwnProperty("reward_icon"))
         {
            if(this.m_rewardItem)
            {
               this.m_rewardicon_mc = new FarmIcon(m_window["reward_icon"],this.m_rewardItem.iconUrl);
               this.m_rewardicon_mc.setIconSize(150,150);
               this.m_rewardicon_mc.visible = true;
            }
         }
         if(m_window.hasOwnProperty("ok_bt"))
         {
            this.m_accept_bt = new FarmAnimatedTextButton(m_window["ok_bt"],"Awesome!",this.onAcceptClick);
            this.m_accept_bt.visible = true;
         }
      }
      
      private function onAcceptClick(e:Event = null) : void
      {
         this.close();
      }
      
      private function get manager() : PunchCardFeatureManager
      {
         return PunchCardFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

