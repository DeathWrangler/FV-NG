package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FarmRunV7Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunV7SingleRewardPopup extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      protected var m_closeBt:FarmButton = null;
      
      protected var subtext1_tf:ZwTextField = null;
      
      protected var subtext2_tf:ZwTextField = null;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private const WORLD_REWARD_NAMES_ARRAY:Array = ["unicorn_bandplayer","pegasus_captain","horse_shackowner","pegasus_cherryblossom"];
      
      private const WORLD_NAMES_ARRAY:Array = ["england","fisherman","hawaii","asia"];
      
      public function FarmRunV7SingleRewardPopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function get manager() : FarmRunV7Manager
      {
         return FarmRunV7Manager.getInstance(this.m_featureName);
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemName:String = null;
         var worldRew:Boolean = false;
         var worldId:int = 0;
         var world:String = null;
         var worldElement:String = null;
         var buttonCallback:Function = null;
         super.postLoadComplete();
         var itemFriendlyTitle:String = "";
         if(this.m_reward != null)
         {
            itemFriendlyTitle = this.m_reward.friendlyTitle;
         }
         itemName = this.m_reward.name;
         var worldReward:Boolean = this.WORLD_REWARD_NAMES_ARRAY.indexOf(itemName) != -1;
         var finalReward:Boolean = itemName == "pegacorn_backpacker";
         var finalworld:Boolean = itemName == this.WORLD_REWARD_NAMES_ARRAY[3];
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"CONGRATS!")) as ZwTextField;
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               this.subtext1_tf = addWidget(new ZwTextField(m_window["subtext1_tf"],"Hurrah! You’ve reached a milestone!")) as ZwTextField;
               if(worldReward)
               {
                  this.subtext1_tf.text = "Hurrah! You\'ve finished this farm! Good show Farmer!";
               }
               if(finalReward)
               {
                  this.subtext1_tf.text = "Hurrah! You’ve completed the Farm Run!";
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               this.subtext2_tf = addWidget(new ZwTextField(m_window["subtext2_tf"],"You\'ve won a " + itemFriendlyTitle + ". Its time to move to the next Farm!")) as ZwTextField;
               if(!worldReward && !finalworld)
               {
                  this.subtext2_tf.text = "You\'ve won a " + itemFriendlyTitle;
               }
               if(finalworld)
               {
                  this.subtext2_tf.text = "You\'ve won a " + itemFriendlyTitle;
               }
               if(finalReward)
               {
                  this.subtext2_tf.text = "Here is your grand prize! You\'ve won a " + itemFriendlyTitle + " !";
               }
            }
            worldRew = worldReward || finalReward;
            if(worldRew)
            {
               if(m_window.hasOwnProperty("share_bt"))
               {
                  this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.shareCallback)) as FarmAnimatedTextButton;
                  this.m_share_bt.visible = true;
               }
            }
            else if(m_window.hasOwnProperty("okay_bt"))
            {
               buttonCallback = Boolean(this.m_callback) ? this.m_callback : this.onClose;
               this.m_okay_bt = addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Awesome",buttonCallback)) as FarmAnimatedTextButton;
               this.m_okay_bt.visible = true;
            }
            world = "";
            if(this.manager)
            {
               world = Global.worldManager.currentWorldType;
            }
            if(Boolean(this.manager) && this.WORLD_NAMES_ARRAY.indexOf(world) == -1)
            {
               world = this.manager.getFarmrunWorldFromPoints();
            }
            if(world != "")
            {
               worldId = this.manager.getworldIndexFromName(world);
            }
            else
            {
               worldId = 3;
            }
            worldElement = "world" + (worldId + 1) + "BG_mc";
            if(m_window.hasOwnProperty(worldElement))
            {
               m_window[worldElement].visible = true;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_window["icon_mc"] as MovieClip,this.m_reward,null,null,[200]),true);
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_closeButton.visible = this.isWorldReward() || this.isFinalReward();
      }
      
      public function isFinalReward() : Boolean
      {
         return this.m_reward.name == "pegacorn_backpacker";
      }
      
      public function isWorldReward() : Boolean
      {
         return this.WORLD_REWARD_NAMES_ARRAY.indexOf(this.m_reward.name) != -1;
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
         super.onClose(event);
      }
      
      private function shareCallback(e:Event) : void
      {
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_reward.icon
            }],
            "user":Global.player.firstName,
            "item":this.m_reward.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("FarmRunV7_share_milestoneReward",bundleData,[],false,null);
         this.onClose(e);
         FarmStatsManager.count("GPF_FarmRunV7","reward_bragfeed",this.m_reward.friendlyTitle);
      }
   }
}

